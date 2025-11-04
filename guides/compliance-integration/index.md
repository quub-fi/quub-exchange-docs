---
layout: docs
title: Compliance Integration
permalink: /guides/compliance-integration/
description: Integrate KYC, AML, and regulatory compliance workflows
---

# Compliance Integration

Integrate KYC, AML, and regulatory compliance into your application.

## KYC Verification

### Submit KYC Data

```javascript
// Submit KYC information
const kyc = await client.identity.submitKyc({
  userId: "user_123",
  firstName: "John",
  lastName: "Doe",
  dateOfBirth: "1990-01-01",
  nationality: "US",
  address: {
    street: "123 Main St",
    city: "New York",
    state: "NY",
    postalCode: "10001",
    country: "US",
  },
  documents: [
    {
      type: "passport",
      number: "P12345678",
      imageUrl: "https://...",
    },
  ],
});

// Check status
const status = await client.identity.getKycStatus(kyc.id);
console.log("KYC Status:", status.state);
```

## Transaction Monitoring

### Monitor for AML

```javascript
// Subscribe to AML alerts
ws.subscribe('compliance.alerts', (alert) => {
  if (alert.severity === 'high') {
    console.log('High-risk transaction detected:', alert);
    // Freeze account pending review
    await client.identity.freezeAccount(alert.userId);
  }
});
```

## Regulatory Reporting

```javascript
// Generate compliance report
const report = await client.compliance.generateReport({
  type: "suspicious_activity",
  startDate: "2024-01-01",
  endDate: "2024-12-31",
  format: "fincen_sar",
});
```

---

**Next Steps:**

- [Identity API]({{ '/capabilities/identity/api-reference/' | relative_url }})
- [Compliance API]({{ '/capabilities/compliance/api-reference/' | relative_url }})
