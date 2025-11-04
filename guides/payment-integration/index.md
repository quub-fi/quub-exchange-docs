---
layout: docs
title: Crypto Payment Integration
permalink: /guides/payment-integration/
description: Accept cryptocurrency payments in your e-commerce or application
---

# Crypto Payment Integration

Accept cryptocurrency payments in your e-commerce platform or application.

## Payment Flow

```
Customer → Checkout → Generate Address → Monitor → Confirm → Complete
```

## Generate Payment Address

```javascript
// Create payment request
const payment = await client.gateway.createPayment({
  amount: "99.99",
  currency: "USD",
  acceptedCurrencies: ["BTC", "ETH", "USDC"],
  orderId: "order_123",
  callbackUrl: "https://your-site.com/payment-callback",
});

console.log("Payment ID:", payment.id);
console.log("BTC Address:", payment.addresses.BTC);
console.log("Amount in BTC:", payment.amounts.BTC);
```

## Monitor Payment

```javascript
// Check payment status
const status = await client.gateway.getPaymentStatus(payment.id);

if (status.state === "confirmed") {
  // Payment received with sufficient confirmations
  await fulfillOrder(status.orderId);
}
```

## Webhook Integration

```javascript
// Handle payment webhooks
app.post("/payment-callback", async (req, res) => {
  const payment = req.body;

  if (payment.state === "confirmed") {
    await db.orders.update(payment.orderId, {
      status: "paid",
      paymentId: payment.id,
      txHash: payment.txHash,
    });

    await sendConfirmationEmail(payment.orderId);
  }

  res.sendStatus(200);
});
```

## Payment Button

```html
<button id="pay-with-crypto">Pay with Crypto</button>

<script>
  document.getElementById("pay-with-crypto").onclick = async () => {
    const payment = await fetch("/api/create-payment", {
      method: "POST",
      body: JSON.stringify({ amount: 99.99, orderId: "order_123" }),
    }).then((r) => r.json());

    // Show payment modal with QR code
    showPaymentModal(payment);
  };
</script>
```

---

**Next Steps:**

- [Gateway API]({{ '/capabilities/gateway/api-reference/' | relative_url }})
- [Fiat Banking]({{ '/capabilities/fiat-banking/api-reference/' | relative_url }})
- [Security Guide]({{ '/guides/getting-started/security-guide/' | relative_url }})
