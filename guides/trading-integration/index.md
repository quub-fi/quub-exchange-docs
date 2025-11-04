---
layout: docs
title: Building a Trading Application
permalink: /guides/trading-integration/
description: Complete guide to building a trading application with Quub Exchange
---

# Building a Trading Application

Learn how to build a complete trading application with order management, real-time market data, and position tracking using Quub Exchange APIs.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Order Management](#order-management)
3. [Real-Time Market Data](#real-time-market-data)
4. [Position Tracking](#position-tracking)
5. [Portfolio Management](#portfolio-management)
6. [Risk Management](#risk-management)
7. [UI Integration](#ui-integration)

---

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────┐
│          Trading Application            │
├─────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │  Order   │  │ Market   │  │Position││
│  │Management│  │  Data    │  │Tracker ││
│  └──────────┘  └──────────┘  └────────┘│
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │Portfolio │  │  Risk    │  │  UI    ││
│  │ Manager  │  │ Manager  │  │ Layer  ││
│  └──────────┘  └──────────┘  └────────┘│
└─────────────────────────────────────────┘
           │
           ▼
    ┌─────────────┐
    │Quub Exchange│
    │    APIs     │
    └─────────────┘
```

### Technology Stack

**Backend:**

- Node.js/TypeScript or Python
- WebSocket for real-time data
- Redis for caching
- PostgreSQL for persistence

**Frontend:**

- React/Vue.js for UI
- TradingView charts
- WebSocket for live updates

---

## Order Management

### Order Types Implementation

```typescript
// types/order.ts
export enum OrderType {
  MARKET = "market",
  LIMIT = "limit",
  STOP = "stop",
  STOP_LIMIT = "stop_limit",
}

export enum OrderSide {
  BUY = "buy",
  SELL = "sell",
}

export enum TimeInForce {
  GTC = "GTC", // Good Till Cancel
  IOC = "IOC", // Immediate or Cancel
  FOK = "FOK", // Fill or Kill
}

export interface OrderParams {
  symbol: string;
  side: OrderSide;
  type: OrderType;
  quantity: string;
  price?: string;
  stopPrice?: string;
  timeInForce: TimeInForce;
  clientOrderId?: string;
}
```

### Order Service

```typescript
// services/order-service.ts
import { QuubClient } from "@quub/sdk";
import { OrderParams, Order } from "../types/order";

export class OrderService {
  private client: QuubClient;
  private activeOrders: Map<string, Order> = new Map();

  constructor(client: QuubClient) {
    this.client = client;
  }

  /**
   * Place a new order with pre-flight checks
   */
  async placeOrder(params: OrderParams): Promise<Order> {
    // 1. Validate parameters
    this.validateOrderParams(params);

    // 2. Check balance
    await this.checkBalance(params);

    // 3. Check risk limits
    await this.checkRiskLimits(params);

    // 4. Place order
    const order = await this.client.exchange.createOrder({
      ...params,
      clientOrderId: params.clientOrderId || this.generateClientOrderId(),
    });

    // 5. Track order
    this.activeOrders.set(order.orderId, order);

    // 6. Emit event
    this.emit("order:created", order);

    return order;
  }

  /**
   * Cancel an existing order
   */
  async cancelOrder(orderId: string): Promise<Order> {
    const order = await this.client.exchange.cancelOrder(orderId);

    this.activeOrders.delete(orderId);
    this.emit("order:cancelled", order);

    return order;
  }

  /**
   * Modify an existing order
   */
  async modifyOrder(
    orderId: string,
    updates: Partial<OrderParams>
  ): Promise<Order> {
    // Cancel old order
    await this.cancelOrder(orderId);

    // Place new order with updates
    const existingOrder = await this.client.exchange.getOrder(orderId);
    const newOrder = await this.placeOrder({
      ...existingOrder,
      ...updates,
    });

    return newOrder;
  }

  /**
   * Get all active orders
   */
  async getActiveOrders(symbol?: string): Promise<Order[]> {
    const orders = await this.client.exchange.getOrders({
      status: "open",
      symbol,
    });

    return orders;
  }

  /**
   * Check if user has sufficient balance
   */
  private async checkBalance(params: OrderParams): Promise<void> {
    const currency =
      params.side === OrderSide.BUY
        ? params.symbol.split("-")[1]
        : params.symbol.split("-")[0];

    const balance = await this.client.custodian.getBalance(currency);

    const required =
      params.side === OrderSide.BUY
        ? parseFloat(params.quantity) * parseFloat(params.price || "0")
        : parseFloat(params.quantity);

    if (parseFloat(balance.available) < required) {
      throw new Error(`Insufficient ${currency} balance`);
    }
  }

  /**
   * Check risk limits before order placement
   */
  private async checkRiskLimits(params: OrderParams): Promise<void> {
    const limits = await this.client.riskLimits.getRiskLimits();

    // Check position limit
    const currentPosition = await this.getCurrentPosition(params.symbol);
    const newPosition = this.calculateNewPosition(currentPosition, params);

    if (Math.abs(newPosition) > limits.maxPosition) {
      throw new Error("Order exceeds position limit");
    }

    // Check order size limit
    if (parseFloat(params.quantity) > limits.maxOrderSize) {
      throw new Error("Order size exceeds limit");
    }
  }

  private validateOrderParams(params: OrderParams): void {
    if (!params.symbol || !params.side || !params.type || !params.quantity) {
      throw new Error("Missing required order parameters");
    }

    if (params.type === OrderType.LIMIT && !params.price) {
      throw new Error("Price required for limit orders");
    }

    if (params.type === OrderType.STOP && !params.stopPrice) {
      throw new Error("Stop price required for stop orders");
    }
  }

  private generateClientOrderId(): string {
    return `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

### Order Execution Monitor

```typescript
// services/execution-monitor.ts
export class OrderExecutionMonitor {
  private orderService: OrderService;
  private ws: WebSocket;

  constructor(orderService: OrderService, client: QuubClient) {
    this.orderService = orderService;
    this.setupWebSocket(client);
  }

  private async setupWebSocket(client: QuubClient) {
    this.ws = await client.exchange.connectWebSocket();

    // Subscribe to order updates
    this.ws.subscribe("orders.updates", ["*"], (update) => {
      this.handleOrderUpdate(update);
    });

    // Subscribe to trade executions
    this.ws.subscribe("trades.user", ["*"], (trade) => {
      this.handleTradeExecution(trade);
    });
  }

  private handleOrderUpdate(update: any) {
    console.log("Order update:", {
      orderId: update.orderId,
      status: update.status,
      filled: update.filledQuantity,
      remaining: update.remainingQuantity,
    });

    // Update UI
    this.emit("order:updated", update);

    // Handle different statuses
    switch (update.status) {
      case "filled":
        this.handleOrderFilled(update);
        break;
      case "partially_filled":
        this.handlePartialFill(update);
        break;
      case "cancelled":
        this.handleOrderCancelled(update);
        break;
      case "rejected":
        this.handleOrderRejected(update);
        break;
    }
  }

  private handleTradeExecution(trade: any) {
    console.log("Trade executed:", {
      orderId: trade.orderId,
      price: trade.price,
      quantity: trade.quantity,
      side: trade.side,
    });

    // Update position
    this.updatePosition(trade);

    // Calculate PnL
    this.calculatePnL(trade);

    // Emit event
    this.emit("trade:executed", trade);
  }
}
```

---

## Real-Time Market Data

### Market Data Service

```typescript
// services/market-data-service.ts
export class MarketDataService {
  private client: QuubClient;
  private ws: WebSocket;
  private subscribers: Map<string, Set<Function>> = new Map();

  async connect() {
    this.ws = await this.client.exchange.connectWebSocket();

    // Subscribe to ticker updates
    this.ws.subscribe("market.ticker", ["*"], (ticker) => {
      this.handleTickerUpdate(ticker);
    });

    // Subscribe to order book updates
    this.ws.subscribe("market.orderbook", ["BTC-USD", "ETH-USD"], (book) => {
      this.handleOrderBookUpdate(book);
    });

    // Subscribe to trades
    this.ws.subscribe("market.trades", ["*"], (trade) => {
      this.handleTradeUpdate(trade);
    });
  }

  /**
   * Subscribe to market data for specific symbols
   */
  subscribeToSymbol(symbol: string, callback: Function) {
    if (!this.subscribers.has(symbol)) {
      this.subscribers.set(symbol, new Set());
    }

    this.subscribers.get(symbol)!.add(callback);
  }

  /**
   * Get current market snapshot
   */
  async getMarketSnapshot(symbol: string) {
    const [ticker, orderBook, recentTrades] = await Promise.all([
      this.client.exchange.getMarket(symbol),
      this.client.exchange.getOrderBook(symbol),
      this.client.exchange.getTrades({ symbol, limit: 50 }),
    ]);

    return {
      ticker,
      orderBook,
      recentTrades,
      timestamp: Date.now(),
    };
  }

  private handleTickerUpdate(ticker: any) {
    const callbacks = this.subscribers.get(ticker.symbol);
    if (callbacks) {
      callbacks.forEach((cb) => cb({ type: "ticker", data: ticker }));
    }
  }

  private handleOrderBookUpdate(book: any) {
    const callbacks = this.subscribers.get(book.symbol);
    if (callbacks) {
      callbacks.forEach((cb) => cb({ type: "orderbook", data: book }));
    }
  }

  private handleTradeUpdate(trade: any) {
    const callbacks = this.subscribers.get(trade.symbol);
    if (callbacks) {
      callbacks.forEach((cb) => cb({ type: "trade", data: trade }));
    }
  }
}
```

### Price Chart Integration

```typescript
// components/PriceChart.tsx
import React, { useEffect, useRef } from "react";
import { createChart, IChartApi } from "lightweight-charts";

export const PriceChart: React.FC<{ symbol: string }> = ({ symbol }) => {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<IChartApi | null>(null);

  useEffect(() => {
    if (!chartContainerRef.current) return;

    // Create chart
    chartRef.current = createChart(chartContainerRef.current, {
      width: chartContainerRef.current.clientWidth,
      height: 400,
      layout: {
        background: { color: "#1e222d" },
        textColor: "#d1d4dc",
      },
      grid: {
        vertLines: { color: "#2b2b43" },
        horzLines: { color: "#2b2b43" },
      },
    });

    const candlestickSeries = chartRef.current.addCandlestickSeries();

    // Load historical data
    loadHistoricalData(symbol).then((data) => {
      candlestickSeries.setData(data);
    });

    // Subscribe to real-time updates
    const unsubscribe = marketDataService.subscribeToSymbol(
      symbol,
      (update) => {
        if (update.type === "ticker") {
          candlestickSeries.update({
            time: Date.now() / 1000,
            open: parseFloat(update.data.open),
            high: parseFloat(update.data.high),
            low: parseFloat(update.data.low),
            close: parseFloat(update.data.lastPrice),
          });
        }
      }
    );

    return () => {
      unsubscribe();
      chartRef.current?.remove();
    };
  }, [symbol]);

  return <div ref={chartContainerRef} />;
};
```

---

## Position Tracking

### Position Manager

```typescript
// services/position-manager.ts
export class PositionManager {
  private positions: Map<string, Position> = new Map();
  private client: QuubClient;

  constructor(client: QuubClient) {
    this.client = client;
  }

  /**
   * Calculate current position for a symbol
   */
  async getCurrentPosition(symbol: string): Promise<Position> {
    // Check cache
    if (this.positions.has(symbol)) {
      return this.positions.get(symbol)!;
    }

    // Fetch from API
    const position = await this.client.exchange.getPosition(symbol);
    this.positions.set(symbol, position);

    return position;
  }

  /**
   * Update position after trade execution
   */
  updatePosition(trade: Trade): void {
    const symbol = trade.symbol;
    const position =
      this.positions.get(symbol) || this.createEmptyPosition(symbol);

    const quantity = parseFloat(trade.quantity);
    const price = parseFloat(trade.price);

    if (trade.side === "buy") {
      // Adding to long position or reducing short position
      position.quantity += quantity;
      position.averagePrice =
        (position.averagePrice * position.quantity + price * quantity) /
        (position.quantity + quantity);
    } else {
      // Adding to short position or reducing long position
      position.quantity -= quantity;
      if (position.quantity < 0) {
        position.averagePrice = price;
      }
    }

    // Calculate unrealized PnL
    position.unrealizedPnL = this.calculateUnrealizedPnL(position, trade.price);

    this.positions.set(symbol, position);
    this.emit("position:updated", position);
  }

  /**
   * Calculate unrealized PnL
   */
  private calculateUnrealizedPnL(
    position: Position,
    currentPrice: string
  ): number {
    const qty = position.quantity;
    const avgPrice = position.averagePrice;
    const curPrice = parseFloat(currentPrice);

    return (curPrice - avgPrice) * qty;
  }

  /**
   * Calculate realized PnL
   */
  calculateRealizedPnL(closedTrade: Trade): number {
    const position = this.positions.get(closedTrade.symbol);
    if (!position) return 0;

    const entryPrice = position.averagePrice;
    const exitPrice = parseFloat(closedTrade.price);
    const quantity = parseFloat(closedTrade.quantity);

    return (exitPrice - entryPrice) * quantity;
  }

  /**
   * Get all open positions
   */
  getOpenPositions(): Position[] {
    return Array.from(this.positions.values()).filter((p) => p.quantity !== 0);
  }
}
```

---

## Portfolio Management

### Portfolio Service

```typescript
// services/portfolio-service.ts
export class PortfolioService {
  private client: QuubClient;
  private positionManager: PositionManager;

  /**
   * Get complete portfolio overview
   */
  async getPortfolioOverview(): Promise<PortfolioOverview> {
    const [balances, positions, pnl] = await Promise.all([
      this.getBalances(),
      this.positionManager.getOpenPositions(),
      this.calculateTotalPnL(),
    ]);

    const totalValue = this.calculateTotalValue(balances, positions);

    return {
      totalValue,
      balances,
      positions,
      pnl,
      allocation: this.calculateAllocation(balances, positions),
      performance: await this.calculatePerformance(),
    };
  }

  /**
   * Calculate portfolio allocation
   */
  private calculateAllocation(
    balances: Balance[],
    positions: Position[]
  ): Allocation[] {
    const totalValue = this.calculateTotalValue(balances, positions);

    const allocation: Allocation[] = [];

    // Add cash allocations
    for (const balance of balances) {
      const value =
        parseFloat(balance.total) * (await this.getUSDPrice(balance.currency));
      allocation.push({
        asset: balance.currency,
        value,
        percentage: (value / totalValue) * 100,
        type: "cash",
      });
    }

    // Add position allocations
    for (const position of positions) {
      const value = Math.abs(position.quantity * position.averagePrice);
      allocation.push({
        asset: position.symbol,
        value,
        percentage: (value / totalValue) * 100,
        type: "position",
      });
    }

    return allocation.sort((a, b) => b.value - a.value);
  }

  /**
   * Calculate portfolio performance
   */
  private async calculatePerformance(): Promise<Performance> {
    const trades = await this.client.exchange.getTrades({
      startDate: this.get30DaysAgo(),
      endDate: Date.now(),
    });

    let totalPnL = 0;
    let winningTrades = 0;
    let losingTrades = 0;

    for (const trade of trades) {
      const pnl = this.calculateTradePnL(trade);
      totalPnL += pnl;

      if (pnl > 0) winningTrades++;
      else if (pnl < 0) losingTrades++;
    }

    return {
      totalPnL,
      winRate: (winningTrades / (winningTrades + losingTrades)) * 100,
      totalTrades: trades.length,
      winningTrades,
      losingTrades,
    };
  }
}
```

---

## Risk Management

### Risk Manager

```typescript
// services/risk-manager.ts
export class RiskManager {
  private client: QuubClient;
  private maxLeverage = 10;
  private maxPositionSize = 1000000; // USD
  private maxDailyLoss = 50000; // USD

  /**
   * Check if order passes risk checks
   */
  async validateOrder(params: OrderParams): Promise<boolean> {
    // Check position size
    if (!(await this.checkPositionSize(params))) {
      throw new Error("Order exceeds maximum position size");
    }

    // Check leverage
    if (!(await this.checkLeverage(params))) {
      throw new Error("Order exceeds maximum leverage");
    }

    // Check daily loss limit
    if (!(await this.checkDailyLoss())) {
      throw new Error("Daily loss limit reached");
    }

    // Check concentration risk
    if (!(await this.checkConcentration(params))) {
      throw new Error("Order would exceed concentration limit");
    }

    return true;
  }

  private async checkPositionSize(params: OrderParams): Promise<boolean> {
    const currentPosition = await this.getCurrentPosition(params.symbol);
    const orderValue =
      parseFloat(params.quantity) * parseFloat(params.price || "0");
    const newPositionSize = Math.abs(currentPosition + orderValue);

    return newPositionSize <= this.maxPositionSize;
  }

  private async checkLeverage(params: OrderParams): Promise<boolean> {
    const equity = await this.getAccountEquity();
    const totalExposure = await this.getTotalExposure();
    const orderExposure =
      parseFloat(params.quantity) * parseFloat(params.price || "0");

    const newLeverage = (totalExposure + orderExposure) / equity;

    return newLeverage <= this.maxLeverage;
  }

  private async checkDailyLoss(): Promise<boolean> {
    const todayPnL = await this.getTodayPnL();
    return todayPnL > -this.maxDailyLoss;
  }
}
```

---

## UI Integration

### Order Entry Component

```tsx
// components/OrderEntry.tsx
import React, { useState } from "react";

export const OrderEntry: React.FC<{ symbol: string }> = ({ symbol }) => {
  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [type, setType] = useState<OrderType>(OrderType.LIMIT);
  const [quantity, setQuantity] = useState("");
  const [price, setPrice] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const order = await orderService.placeOrder({
        symbol,
        side,
        type,
        quantity,
        price,
        timeInForce: TimeInForce.GTC,
      });

      toast.success(`Order placed: ${order.orderId}`);
    } catch (error) {
      toast.error(`Order failed: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="order-entry">
      <div className="tabs">
        <button
          className={side === "buy" ? "active buy" : "buy"}
          onClick={() => setSide("buy")}
        >
          Buy
        </button>
        <button
          className={side === "sell" ? "active sell" : "sell"}
          onClick={() => setSide("sell")}
        >
          Sell
        </button>
      </div>

      <form onSubmit={handleSubmit}>
        <select
          value={type}
          onChange={(e) => setType(e.target.value as OrderType)}
        >
          <option value="market">Market</option>
          <option value="limit">Limit</option>
          <option value="stop">Stop</option>
        </select>

        <input
          type="number"
          placeholder="Quantity"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
          required
        />

        {type !== "market" && (
          <input
            type="number"
            placeholder="Price"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            required
          />
        )}

        <button type="submit" className={`submit ${side}`} disabled={loading}>
          {loading ? "Placing..." : `Place ${side} Order`}
        </button>
      </form>
    </div>
  );
};
```

---

## Next Steps

- **[Market Data Guide](../market-data/)** - Deep dive into market data integration
- **[Risk Management](../risk-management/)** - Advanced risk management strategies
- **[Production Deployment](../production-deployment/)** - Deploy your trading app

---

**Need Help?** Contact support@quub.fi or join our [Community Forum](#)
