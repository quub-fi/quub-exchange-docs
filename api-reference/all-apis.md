---
layout: default
title: Complete API Overview
permalink: /api-reference/all-apis/
description: Comprehensive overview of all 26 Quub Exchange APIs with capabilities, use cases, and quick reference
---

<style>
.api-overview-header {
  text-align: center;
  padding: 3rem 2rem;
  background: linear-gradient(135deg, #1a1f36 0%, #2d3748 100%);
  border-radius: 12px;
  margin-bottom: 3rem;
}

.api-overview-header h1 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.api-overview-header p {
  font-size: 1.2rem;
  color: #a0aec0;
  max-width: 800px;
  margin: 0 auto;
}

.api-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0 3rem 0;
}

.api-stat-card {
  background: #1a202c;
  border: 1px solid #2d3748;
  border-radius: 8px;
  padding: 1.5rem;
  text-align: center;
}

.api-stat-card .stat-number {
  font-size: 2.5rem;
  font-weight: bold;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  display: block;
  margin-bottom: 0.5rem;
}

.api-stat-card .stat-label {
  color: #a0aec0;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.api-category {
  margin-bottom: 4rem;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #2d3748;
}

.category-icon {
  font-size: 2rem;
}

.category-header h2 {
  margin: 0;
  font-size: 1.8rem;
}

.category-description {
  color: #a0aec0;
  margin-bottom: 2rem;
  font-size: 1.1rem;
}

.api-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.api-card {
  background: #1a202c;
  border: 1px solid #2d3748;
  border-radius: 8px;
  padding: 1.5rem;
  transition: all 0.3s ease;
  position: relative;
}

.api-card:hover {
  transform: translateY(-4px);
  border-color: #667eea;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
}

.api-card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.api-icon {
  font-size: 1.5rem;
}

.api-card h3 {
  margin: 0;
  font-size: 1.3rem;
}

.api-card h3 a {
  color: #e2e8f0;
  text-decoration: none;
}

.api-card h3 a:hover {
  color: #667eea;
}

.api-version {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: #2d3748;
  color: #667eea;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.api-description {
  color: #a0aec0;
  margin-bottom: 1rem;
  line-height: 1.6;
}

.api-features {
  margin: 1rem 0;
}

.api-features h4 {
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #718096;
  margin-bottom: 0.5rem;
}

.api-features ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.api-features li {
  color: #a0aec0;
  padding: 0.25rem 0;
  font-size: 0.9rem;
}

.api-features li:before {
  content: "✓";
  color: #48bb78;
  font-weight: bold;
  margin-right: 0.5rem;
}

.api-links {
  display: flex;
  gap: 0.75rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #2d3748;
}

.api-link {
  flex: 1;
  text-align: center;
  padding: 0.5rem;
  background: #2d3748;
  border-radius: 6px;
  text-decoration: none;
  color: #e2e8f0;
  font-size: 0.85rem;
  transition: all 0.2s ease;
}

.api-link:hover {
  background: #667eea;
  color: white;
}

.quick-ref-section {
  background: #1a202c;
  border: 1px solid #2d3748;
  border-radius: 8px;
  padding: 2rem;
  margin-top: 3rem;
}

.quick-ref-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 1.5rem;
}

.quick-ref-item h4 {
  color: #667eea;
  margin-bottom: 0.5rem;
}

.quick-ref-item ul {
  list-style: none;
  padding: 0;
}

.quick-ref-item li {
  color: #a0aec0;
  padding: 0.25rem 0;
  font-size: 0.9rem;
}

.integration-paths {
  margin: 3rem 0;
  padding: 2rem;
  background: #1a202c;
  border: 1px solid #2d3748;
  border-radius: 8px;
}

.path-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.path-card {
  background: #2d3748;
  padding: 1.5rem;
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

.path-card h4 {
  margin-top: 0;
  color: #e2e8f0;
}

.path-apis {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-top: 1rem;
}

.path-api-tag {
  background: #1a202c;
  color: #a0aec0;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  border: 1px solid #4a5568;
}
</style>

<div class="api-overview-header">
  <h1>🎯 Complete API Reference</h1>
  <p>Explore all 26 Quub Exchange APIs organized by functionality. Build everything from simple trading bots to complete financial infrastructure.</p>
</div>

<div class="api-stats">
  <div class="api-stat-card">
    <span class="stat-number">26</span>
    <span class="stat-label">Total APIs</span>
  </div>
  <div class="api-stat-card">
    <span class="stat-number">7</span>
    <span class="stat-label">Categories</span>
  </div>
  <div class="api-stat-card">
    <span class="stat-number">200+</span>
    <span class="stat-label">Endpoints</span>
  </div>
  <div class="api-stat-card">
    <span class="stat-number">REST + WS</span>
    <span class="stat-label">Protocols</span>
  </div>
</div>

<!-- Core Platform -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">🔐</span>
    <h2>Core Platform</h2>
  </div>
  <p class="category-description">
    Essential authentication, identity management, and multi-tenancy services that form the foundation of every integration.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🔑</span>
        <h3><a href="{{ '/capabilities/auth/api-documentation/' | relative_url }}">Authentication Service</a></h3>
      </div>
      <p class="api-description">
        Secure authentication, session management, and access control. OAuth 2.0, JWT tokens, API keys, and MFA support.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>OAuth 2.0 & OpenID Connect</li>
          <li>JWT token management</li>
          <li>API key generation & rotation</li>
          <li>Multi-factor authentication</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/auth/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/auth/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/auth.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">👤</span>
        <h3><a href="{{ '/capabilities/identity/api-documentation/' | relative_url }}">Identity Service</a></h3>
      </div>
      <p class="api-description">
        User identity, KYC/AML verification, and profile management. Complete customer onboarding workflows.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>KYC/AML verification</li>
          <li>Document verification</li>
          <li>Profile management</li>
          <li>Compliance screening</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/identity/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/identity/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/identity.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🏢</span>
        <h3><a href="{{ '/capabilities/tenancy-trust/api-documentation/' | relative_url }}">Tenancy & Trust</a></h3>
      </div>
      <p class="api-description">
        Multi-tenant isolation, organization management, and trust relationships. Perfect for B2B platforms.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Multi-tenant architecture</li>
          <li>Organization hierarchies</li>
          <li>Trust relationships</li>
          <li>Data isolation</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/tenancy-trust/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/tenancy-trust/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/tenancy-trust.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Trading & Markets -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">📈</span>
    <h2>Trading & Markets</h2>
  </div>
  <p class="category-description">
    Core trading infrastructure including order management, market data, price discovery, and liquidity aggregation.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">💹</span>
        <h3><a href="{{ '/capabilities/exchange/api-documentation/' | relative_url }}">Exchange API</a></h3>
      </div>
      <p class="api-description">
        Order management, matching engine, market data, order books. Build complete trading applications.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Market, limit, stop orders</li>
          <li>Real-time order books</li>
          <li>WebSocket market data</li>
          <li>Portfolio management</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/exchange/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/exchange/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/exchange.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🏪</span>
        <h3><a href="{{ '/capabilities/marketplace/api-documentation/' | relative_url }}">Marketplace API</a></h3>
      </div>
      <p class="api-description">
        Peer-to-peer trading, OTC desk, order book creation. Enable users to trade directly with each other.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>P2P trading platform</li>
          <li>OTC desk management</li>
          <li>Custom order books</li>
          <li>Negotiation workflows</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/marketplace/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/marketplace/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/marketplace.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🌉</span>
        <h3><a href="{{ '/capabilities/gateway/api-documentation/' | relative_url }}">Gateway API</a></h3>
      </div>
      <p class="api-description">
        Liquidity aggregation, smart order routing, multi-exchange connectivity. Best execution across venues.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Multi-venue aggregation</li>
          <li>Smart order routing</li>
          <li>Best execution</li>
          <li>Unified order book</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/gateway/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/gateway/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/gateway.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🔮</span>
        <h3><a href="{{ '/capabilities/market-oracles/api-documentation/' | relative_url }}">Market Oracles</a></h3>
      </div>
      <p class="api-description">
        Price feeds, market indicators, oracle data. Reliable price data for DeFi and trading applications.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Real-time price feeds</li>
          <li>Historical OHLCV data</li>
          <li>Market indicators</li>
          <li>Oracle attestations</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/market-oracles/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/market-oracles/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/market-oracles.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📊</span>
        <h3><a href="{{ '/capabilities/pricing-refdata/api-documentation/' | relative_url }}">Pricing & RefData</a></h3>
      </div>
      <p class="api-description">
        Reference data, asset information, pricing models. Master data management for financial instruments.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Asset master data</li>
          <li>Pricing models</li>
          <li>Market references</li>
          <li>Data validation</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/pricing-refdata/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/pricing-refdata/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/pricing-refdata.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Financial Services -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">💰</span>
    <h2>Financial Services</h2>
  </div>
  <p class="category-description">
    Comprehensive financial infrastructure including custody, treasury, banking, settlements, and billing.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🔐</span>
        <h3><a href="{{ '/capabilities/custodian/api-documentation/' | relative_url }}">Custodian API</a></h3>
      </div>
      <p class="api-description">
        Digital asset custody, wallet management, multi-sig wallets. Institutional-grade asset security.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Multi-sig wallets</li>
          <li>Cold/hot storage</li>
          <li>Withdrawal policies</li>
          <li>Audit trails</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/custodian/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/custodian/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/custodian.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🏦</span>
        <h3><a href="{{ '/capabilities/treasury/api-documentation/' | relative_url }}">Treasury API</a></h3>
      </div>
      <p class="api-description">
        Liquidity management, asset allocation, yield optimization. Enterprise treasury operations.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Liquidity pools</li>
          <li>Asset allocation</li>
          <li>Yield strategies</li>
          <li>Cash management</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/treasury/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/treasury/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/treasury.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🏧</span>
        <h3><a href="{{ '/capabilities/fiat-banking/api-documentation/' | relative_url }}">Fiat Banking</a></h3>
      </div>
      <p class="api-description">
        Bank account linking, ACH/wire transfers, fiat on/off ramps. Seamless fiat-crypto conversions.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Bank account linking</li>
          <li>ACH/SEPA transfers</li>
          <li>Wire transfers</li>
          <li>Fiat on/off ramps</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/fiat-banking/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/fiat-banking/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/fiat-banking.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">⚖️</span>
        <h3><a href="{{ '/capabilities/settlements/api-documentation/' | relative_url }}">Settlements API</a></h3>
      </div>
      <p class="api-description">
        Trade clearing, settlement cycles, delivery vs payment. Post-trade processing and settlement.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Trade clearing</li>
          <li>DVP settlement</li>
          <li>Netting engines</li>
          <li>Settlement cycles</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/settlements/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/settlements/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/settlements.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🔒</span>
        <h3><a href="{{ '/capabilities/escrow/api-documentation/' | relative_url }}">Escrow API</a></h3>
      </div>
      <p class="api-description">
        Escrow accounts, conditional releases, milestone payments. Secure peer-to-peer transactions.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Escrow accounts</li>
          <li>Conditional releases</li>
          <li>Milestone payments</li>
          <li>Dispute resolution</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/escrow/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/escrow/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/escrow.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">💳</span>
        <h3><a href="{{ '/capabilities/fees-billing/api-documentation/' | relative_url }}">Fees & Billing</a></h3>
      </div>
      <p class="api-description">
        Fee calculation, billing, invoicing, subscriptions. Complete monetization infrastructure.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Dynamic fee models</li>
          <li>Invoice generation</li>
          <li>Subscription billing</li>
          <li>Revenue reporting</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/fees-billing/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/fees-billing/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/fees-billing.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Capital Markets -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">🏛️</span>
    <h2>Capital Markets</h2>
  </div>
  <p class="category-description">
    Securities issuance, transfer agent services, corporate actions, and governance for digital securities.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📜</span>
        <h3><a href="{{ '/capabilities/primary-market/api-documentation/' | relative_url }}">Primary Market</a></h3>
      </div>
      <p class="api-description">
        Token issuance, ICOs, STOs, securities offerings. Launch and manage primary market events.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Token issuance</li>
          <li>ICO/STO management</li>
          <li>Cap table management</li>
          <li>Allocation workflows</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/primary-market/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/primary-market/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/primary-market.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📋</span>
        <h3><a href="{{ '/capabilities/transfer-agent/api-documentation/' | relative_url }}">Transfer Agent</a></h3>
      </div>
      <p class="api-description">
        Shareholder registry, transfer restrictions, corporate actions. Complete transfer agent services.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Shareholder registry</li>
          <li>Transfer restrictions</li>
          <li>Corporate actions</li>
          <li>Dividend distributions</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/transfer-agent/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/transfer-agent/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/transfer-agent.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🗳️</span>
        <h3><a href="{{ '/capabilities/governance/api-documentation/' | relative_url }}">Governance API</a></h3>
      </div>
      <p class="api-description">
        Voting, proposals, on-chain governance. Democratic decision-making for DAOs and protocols.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Proposal creation</li>
          <li>Voting mechanisms</li>
          <li>Delegation systems</li>
          <li>Execution workflows</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/governance/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/governance/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/governance.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Compliance & Risk -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">🛡️</span>
    <h2>Compliance & Risk Management</h2>
  </div>
  <p class="category-description">
    Regulatory compliance, risk management, position limits, and document management for regulated environments.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">✅</span>
        <h3><a href="{{ '/capabilities/compliance/api-documentation/' | relative_url }}">Compliance API</a></h3>
      </div>
      <p class="api-description">
        AML/KYC, transaction monitoring, sanctions screening. Comprehensive compliance automation.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Transaction monitoring</li>
          <li>Sanctions screening</li>
          <li>SAR filing</li>
          <li>Compliance reporting</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/compliance/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/compliance/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/compliance.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">⚠️</span>
        <h3><a href="{{ '/capabilities/risk-limits/api-documentation/' | relative_url }}">Risk & Limits</a></h3>
      </div>
      <p class="api-description">
        Position limits, exposure monitoring, risk controls. Real-time risk management infrastructure.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Position limits</li>
          <li>Exposure monitoring</li>
          <li>Pre-trade checks</li>
          <li>Risk reporting</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/risk-limits/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/risk-limits/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/risk-limits.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📁</span>
        <h3><a href="{{ '/capabilities/documents/api-documentation/' | relative_url }}">Documents API</a></h3>
      </div>
      <p class="api-description">
        Document storage, e-signatures, audit trails. Secure document management and compliance archival.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Document storage</li>
          <li>E-signature workflows</li>
          <li>Version control</li>
          <li>Compliance archival</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/documents/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/documents/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/documents.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Infrastructure -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">🔧</span>
    <h2>Infrastructure & Integration</h2>
  </div>
  <p class="category-description">
    Blockchain connectivity, event streaming, notifications, and observability for robust platform integration.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">⛓️</span>
        <h3><a href="{{ '/capabilities/chain/api-documentation/' | relative_url }}">Chain API</a></h3>
      </div>
      <p class="api-description">
        Blockchain connectivity, smart contract interaction, transaction monitoring. Multi-chain support.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Multi-chain support</li>
          <li>Smart contract calls</li>
          <li>Transaction tracking</li>
          <li>Block monitoring</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/chain/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/chain/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/chain.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">⚡</span>
        <h3><a href="{{ '/capabilities/events/api-documentation/' | relative_url }}">Events API</a></h3>
      </div>
      <p class="api-description">
        Event streaming, webhooks, real-time notifications. Build reactive event-driven applications.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Event streaming</li>
          <li>Webhook subscriptions</li>
          <li>Event replay</li>
          <li>Message queuing</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/events/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/events/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/events.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🔔</span>
        <h3><a href="{{ '/capabilities/notifications/api-documentation/' | relative_url }}">Notifications API</a></h3>
      </div>
      <p class="api-description">
        Multi-channel notifications: email, SMS, push. Keep users informed across all channels.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Email notifications</li>
          <li>SMS alerts</li>
          <li>Push notifications</li>
          <li>Template management</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/notifications/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/notifications/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/notifications.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📡</span>
        <h3><a href="{{ '/capabilities/observability/api-documentation/' | relative_url }}">Observability API</a></h3>
      </div>
      <p class="api-description">
        Metrics, logs, traces, health checks. Complete observability for production systems.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Metrics collection</li>
          <li>Log aggregation</li>
          <li>Distributed tracing</li>
          <li>Health monitoring</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/observability/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/observability/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/observability.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Analytics & Reporting -->
<div class="api-category">
  <div class="category-header">
    <span class="category-icon">📊</span>
    <h2>Analytics & Reporting</h2>
  </div>
  <p class="category-description">
    Business intelligence, reporting, and sandbox environments for testing and development.
  </p>

  <div class="api-grid">
    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">📈</span>
        <h3><a href="{{ '/capabilities/analytics-reports/api-documentation/' | relative_url }}">Analytics & Reports</a></h3>
      </div>
      <p class="api-description">
        Business intelligence, custom reports, dashboards. Data-driven insights and analytics.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Custom reports</li>
          <li>Dashboard creation</li>
          <li>Data export</li>
          <li>Scheduled reports</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/analytics-reports/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/analytics-reports/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/analytics-reports.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

    <div class="api-card">
      <span class="api-version">v2.0.0</span>
      <div class="api-card-header">
        <span class="api-icon">🧪</span>
        <h3><a href="{{ '/capabilities/sandbox/api-documentation/' | relative_url }}">Sandbox API</a></h3>
      </div>
      <p class="api-description">
        Testing environment, mock data, simulation tools. Safe environment for development and testing.
      </p>
      <div class="api-features">
        <h4>Key Features</h4>
        <ul>
          <li>Test environment</li>
          <li>Mock data generation</li>
          <li>Simulation tools</li>
          <li>Reset capabilities</li>
        </ul>
      </div>
      <div class="api-links">
        <a href="{{ '/capabilities/sandbox/api-documentation/' | relative_url }}" class="api-link">📖 Docs</a>
        <a href="{{ '/capabilities/sandbox/api-reference/' | relative_url }}" class="api-link">🔍 API Ref</a>
        <a href="{{ '/openapi/sandbox.yaml' | relative_url }}" class="api-link">📄 OpenAPI</a>
      </div>
    </div>

  </div>
</div>

<!-- Common Integration Paths -->
<div class="integration-paths">
  <h2>🎯 Common Integration Paths</h2>
  <p style="color: #a0aec0; margin-bottom: 1.5rem;">Choose a path based on your use case. These are the most common API combinations for different scenarios.</p>

  <div class="path-grid">
    <div class="path-card">
      <h4>🚀 Quick Start (Basic Trading)</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Get started with basic trading in under 30 minutes</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Exchange</span>
        <span class="path-api-tag">Custodian</span>
      </div>
    </div>

    <div class="path-card">
      <h4>💹 Complete Exchange Platform</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Build a full-featured cryptocurrency exchange</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Identity</span>
        <span class="path-api-tag">Exchange</span>
        <span class="path-api-tag">Custodian</span>
        <span class="path-api-tag">Fiat Banking</span>
        <span class="path-api-tag">Compliance</span>
        <span class="path-api-tag">Risk & Limits</span>
      </div>
    </div>

    <div class="path-card">
      <h4>🏦 DeFi Platform</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Launch decentralized finance applications</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Chain</span>
        <span class="path-api-tag">Market Oracles</span>
        <span class="path-api-tag">Treasury</span>
        <span class="path-api-tag">Governance</span>
      </div>
    </div>

    <div class="path-card">
      <h4>💳 Payment Gateway</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Accept crypto payments in your application</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Gateway</span>
        <span class="path-api-tag">Custodian</span>
        <span class="path-api-tag">Pricing & RefData</span>
        <span class="path-api-tag">Notifications</span>
      </div>
    </div>

    <div class="path-card">
      <h4>🏛️ Securities Platform (STO)</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Issue and manage digital securities</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Identity</span>
        <span class="path-api-tag">Primary Market</span>
        <span class="path-api-tag">Transfer Agent</span>
        <span class="path-api-tag">Compliance</span>
        <span class="path-api-tag">Documents</span>
      </div>
    </div>

    <div class="path-card">
      <h4>📊 Trading Analytics Platform</h4>
      <p style="color: #a0aec0; font-size: 0.9rem;">Build data-driven trading tools and analytics</p>
      <div class="path-apis">
        <span class="path-api-tag">Auth</span>
        <span class="path-api-tag">Exchange</span>
        <span class="path-api-tag">Market Oracles</span>
        <span class="path-api-tag">Analytics & Reports</span>
        <span class="path-api-tag">Events</span>
      </div>
    </div>

  </div>
</div>

<!-- Quick Reference -->
<div class="quick-ref-section">
  <h2>⚡ Quick Reference</h2>

  <div class="quick-ref-grid">
    <div class="quick-ref-item">
      <h4>Authentication</h4>
      <ul>
        <li>Base URL: <code>https://api.quub.fi</code></li>
        <li>Auth: Bearer token (JWT)</li>
        <li>Rate limit: 100 req/min</li>
        <li>WebSocket: <code>wss://ws.quub.fi</code></li>
      </ul>
    </div>

    <div class="quick-ref-item">
      <h4>SDKs & Tools</h4>
      <ul>
        <li><a href="#">JavaScript/Node.js SDK</a></li>
        <li><a href="#">Python SDK</a></li>
        <li><a href="#">Postman Collection</a></li>
        <li><a href="{{ '/openapi/' | relative_url }}">OpenAPI Specs</a></li>
      </ul>
    </div>

    <div class="quick-ref-item">
      <h4>Developer Resources</h4>
      <ul>
        <li><a href="{{ '/guides/getting-started/quick-start/' | relative_url }}">Quick Start Guide</a></li>
        <li><a href="{{ '/guides/' | relative_url }}">Integration Guides</a></li>
        <li><a href="{{ '/docs/' | relative_url }}">Documentation</a></li>
        <li><a href="#">API Status</a></li>
      </ul>
    </div>

    <div class="quick-ref-item">
      <h4>Support</h4>
      <ul>
        <li><a href="#">Community Forum</a></li>
        <li><a href="#">Stack Overflow</a></li>
        <li>Email: <a href="mailto:support@quub.fi">support@quub.fi</a></li>
        <li><a href="#">Report an Issue</a></li>
      </ul>
    </div>

  </div>
</div>

<div style="text-align: center; margin-top: 4rem; padding: 2rem; background: #1a202c; border-radius: 8px;">
  <h3>Ready to Get Started?</h3>
  <p style="color: #a0aec0; margin-bottom: 1.5rem;">Create your free account and start building in minutes</p>
  <a href="{{ '/guides/getting-started/quick-start/' | relative_url }}" style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 1rem 2rem; border-radius: 8px; text-decoration: none; font-weight: 600;">Get Started →</a>
</div>
