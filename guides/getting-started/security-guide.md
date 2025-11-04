---
layout: docs
title: Security Guide
permalink: /guides/getting-started/security-guide/
description: Comprehensive security best practices for Quub Exchange integrations
---

# Security Guide

Enterprise-grade security practices for protecting your Quub Exchange integration, user data, and financial operations.

## Table of Contents

1. [API Key Security](#api-key-security)
2. [Authentication & Authorization](#authentication--authorization)
3. [Data Protection](#data-protection)
4. [Network Security](#network-security)
5. [Compliance](#compliance)
6. [Incident Response](#incident-response)
7. [Security Checklist](#security-checklist)

---

## API Key Security

### Key Management Best Practices

```javascript
// ✅ GOOD: Environment variables + Secret management
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

class SecureCredentialManager {
  constructor() {
    this.secretsClient = new SecretsManagerClient({
      region: process.env.AWS_REGION,
    });
    this.cache = new Map();
    this.cacheTTL = 3600000; // 1 hour
  }

  async getCredentials() {
    const cached = this.cache.get("quub-credentials");
    if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
      return cached.value;
    }

    const response = await this.secretsClient.send(
      new GetSecretValueCommand({
        SecretId: process.env.QUUB_SECRET_ARN,
      })
    );

    const credentials = JSON.parse(response.SecretString);

    this.cache.set("quub-credentials", {
      value: credentials,
      timestamp: Date.now(),
    });

    return credentials;
  }

  clearCache() {
    this.cache.clear();
  }
}

// ❌ BAD: Hardcoded credentials
const apiKey = "qk_live_1234567890abcdef";
const apiSecret = "sk_live_abcdef1234567890";
```

### Key Rotation Strategy

```javascript
class ApiKeyRotationManager {
  constructor(quubClient, secretManager) {
    this.client = quubClient;
    this.secretManager = secretManager;
    this.rotationIntervalDays = 90;
  }

  async rotateKeys() {
    console.log("🔄 Starting API key rotation...");

    try {
      // Step 1: Generate new API key pair
      const newKeys = await this.client.auth.createApiKey({
        name: `Production Key ${new Date().toISOString()}`,
        scopes: ["trading:read", "trading:write", "accounts:read"],
        expiresIn: "90d",
      });

      console.log("✅ New keys generated");

      // Step 2: Update secret manager with new keys
      await this.secretManager.updateSecret({
        SecretId: process.env.QUUB_SECRET_ARN,
        SecretString: JSON.stringify({
          apiKey: newKeys.apiKey,
          apiSecret: newKeys.apiSecret,
          orgId: process.env.QUUB_ORG_ID,
          createdAt: newKeys.createdAt,
          expiresAt: newKeys.expiresAt,
        }),
      });

      console.log("✅ Secret manager updated");

      // Step 3: Wait for propagation (5 minutes)
      console.log("⏳ Waiting for key propagation...");
      await this.sleep(300000);

      // Step 4: Revoke old keys
      const oldKeys = await this.client.auth.listApiKeys();
      for (const key of oldKeys) {
        if (key.id !== newKeys.id) {
          await this.client.auth.revokeApiKey(key.id);
          console.log(`🗑️ Revoked old key: ${key.id}`);
        }
      }

      // Step 5: Notify monitoring systems
      await this.notifyKeyRotation(newKeys);

      console.log("✅ Key rotation complete");
    } catch (error) {
      console.error("❌ Key rotation failed:", error);
      await this.alertSecurityTeam({
        severity: "high",
        message: "API key rotation failed",
        error: error.message,
      });
      throw error;
    }
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Schedule rotation
const rotationManager = new ApiKeyRotationManager(quubClient, secretManager);
setInterval(() => rotationManager.rotateKeys(), 90 * 24 * 60 * 60 * 1000); // 90 days
```

### API Key Scopes

```javascript
// Principle of least privilege - use scoped keys

// ✅ GOOD: Read-only key for analytics
const analyticsClient = new QuubClient({
  apiKey: process.env.QUUB_ANALYTICS_KEY,
  apiSecret: process.env.QUUB_ANALYTICS_SECRET,
  scopes: ["markets:read", "analytics:read"],
});

// ✅ GOOD: Limited scope for trading bot
const tradingClient = new QuubClient({
  apiKey: process.env.QUUB_TRADING_KEY,
  apiSecret: process.env.QUUB_TRADING_SECRET,
  scopes: ["trading:read", "trading:write", "accounts:read"],
});

// ❌ BAD: Full access everywhere
const adminClient = new QuubClient({
  apiKey: process.env.QUUB_ADMIN_KEY,
  apiSecret: process.env.QUUB_ADMIN_SECRET,
  scopes: ["*"], // Too permissive!
});
```

---

## Authentication & Authorization

### Multi-Factor Authentication

```javascript
class MFAAuthHandler {
  async authenticate(credentials) {
    // Step 1: Verify API credentials
    const authResult = await quubClient.auth.authenticate({
      apiKey: credentials.apiKey,
      apiSecret: credentials.apiSecret,
    });

    if (!authResult.mfaRequired) {
      return authResult.token;
    }

    // Step 2: Send MFA challenge
    await this.sendMFAChallenge(credentials.userId, authResult.challengeId);

    // Step 3: Wait for MFA verification
    const mfaCode = await this.promptForMFA();

    // Step 4: Verify MFA
    const verifyResult = await quubClient.auth.verifyMFA({
      challengeId: authResult.challengeId,
      code: mfaCode,
    });

    if (!verifyResult.success) {
      throw new Error("MFA verification failed");
    }

    return verifyResult.token;
  }

  async sendMFAChallenge(userId, challengeId) {
    // Send via SMS, email, or authenticator app
    await quubClient.notifications.send({
      userId,
      channel: "sms",
      template: "mfa_challenge",
      data: { challengeId },
    });
  }
}
```

### JWT Token Management

```javascript
class TokenManager {
  constructor() {
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
  }

  async getValidToken() {
    // Return cached token if still valid (with 5-minute buffer)
    if (this.accessToken && Date.now() < this.expiresAt - 300000) {
      return this.accessToken;
    }

    // Refresh token if expired
    if (this.refreshToken) {
      return await this.refreshAccessToken();
    }

    // Otherwise, authenticate
    return await this.authenticate();
  }

  async authenticate() {
    const response = await quubClient.auth.authenticate({
      apiKey: process.env.QUUB_API_KEY,
      apiSecret: process.env.QUUB_API_SECRET,
    });

    this.accessToken = response.accessToken;
    this.refreshToken = response.refreshToken;
    this.expiresAt = Date.now() + response.expiresIn * 1000;

    return this.accessToken;
  }

  async refreshAccessToken() {
    try {
      const response = await quubClient.auth.refreshToken({
        refreshToken: this.refreshToken,
      });

      this.accessToken = response.accessToken;
      this.expiresAt = Date.now() + response.expiresIn * 1000;

      return this.accessToken;
    } catch (error) {
      // If refresh fails, re-authenticate
      console.warn("Token refresh failed, re-authenticating...");
      return await this.authenticate();
    }
  }

  revokeTokens() {
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
  }
}
```

### IP Whitelisting

```javascript
// Configure IP whitelist in Quub dashboard or via API
await quubClient.auth.updateSecuritySettings({
  ipWhitelist: [
    "203.0.113.0/24", // Office network
    "198.51.100.0/24", // Data center
    "192.0.2.50", // Specific server
  ],
  enforceWhitelist: true,
});

// Validate IP on your side as well
class IPValidator {
  constructor(allowedRanges) {
    this.allowedRanges = allowedRanges;
  }

  isAllowed(clientIP) {
    return this.allowedRanges.some((range) => this.ipInRange(clientIP, range));
  }

  ipInRange(ip, range) {
    // IP range validation logic
    const [rangeIP, bits] = range.split("/");
    // Implementation details...
    return true; // Simplified
  }
}

// Express middleware
app.use((req, res, next) => {
  const clientIP = req.ip;
  const validator = new IPValidator(process.env.ALLOWED_IPS.split(","));

  if (!validator.isAllowed(clientIP)) {
    return res.status(403).json({ error: "IP not whitelisted" });
  }

  next();
});
```

---

## Data Protection

### Encryption at Rest

```javascript
import crypto from "crypto";

class DataEncryption {
  constructor() {
    this.algorithm = "aes-256-gcm";
    this.key = crypto.scryptSync(process.env.ENCRYPTION_KEY, "salt", 32);
  }

  encrypt(data) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);

    let encrypted = cipher.update(JSON.stringify(data), "utf8", "hex");
    encrypted += cipher.final("hex");

    const authTag = cipher.getAuthTag();

    return {
      encrypted,
      iv: iv.toString("hex"),
      authTag: authTag.toString("hex"),
    };
  }

  decrypt(encryptedData) {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(encryptedData.iv, "hex")
    );

    decipher.setAuthTag(Buffer.from(encryptedData.authTag, "hex"));

    let decrypted = decipher.update(encryptedData.encrypted, "hex", "utf8");
    decrypted += decipher.final("utf8");

    return JSON.parse(decrypted);
  }
}

// Usage: Encrypt sensitive data before storing
const encryption = new DataEncryption();

// Encrypt API response before caching
const marketData = await quubClient.exchange.getMarket("BTC-USD");
const encrypted = encryption.encrypt(marketData);
await redis.set("market:BTC-USD", JSON.stringify(encrypted));

// Decrypt when retrieving
const cached = JSON.parse(await redis.get("market:BTC-USD"));
const decrypted = encryption.decrypt(cached);
```

### PII Data Handling

```javascript
class PIIHandler {
  constructor() {
    this.sensitiveFields = [
      "ssn",
      "taxId",
      "driverLicense",
      "passportNumber",
      "accountNumber",
    ];
  }

  // Mask PII in logs
  maskPII(data) {
    if (typeof data !== "object") return data;

    const masked = { ...data };

    for (const field of this.sensitiveFields) {
      if (masked[field]) {
        masked[field] = this.mask(masked[field]);
      }
    }

    return masked;
  }

  mask(value) {
    const str = String(value);
    if (str.length <= 4) return "****";
    return str.slice(0, 2) + "*".repeat(str.length - 4) + str.slice(-2);
  }

  // Hash PII for lookup without storing plaintext
  hashPII(value) {
    return crypto
      .createHash("sha256")
      .update(value + process.env.PII_SALT)
      .digest("hex");
  }
}

// Usage
const piiHandler = new PIIHandler();

// Safe logging
logger.info(
  "User registered",
  piiHandler.maskPII({
    userId: user.id,
    email: user.email,
    ssn: user.ssn, // Will be masked
  })
);

// Safe storage
const userRecord = {
  userId: user.id,
  email: user.email,
  ssnHash: piiHandler.hashPII(user.ssn), // Store hash, not plaintext
};
```

### Secure Data Transmission

```javascript
import https from "https";
import fs from "fs";

// Enforce TLS 1.2+
const secureAgent = new https.Agent({
  minVersion: "TLSv1.2",
  maxVersion: "TLSv1.3",
  ciphers: [
    "TLS_AES_256_GCM_SHA384",
    "TLS_CHACHA20_POLY1305_SHA256",
    "TLS_AES_128_GCM_SHA256",
  ].join(":"),

  // Certificate pinning
  ca: fs.readFileSync("./certs/quub-ca.pem"),
  rejectUnauthorized: true,
  checkServerIdentity: (host, cert) => {
    const expectedFingerprint = process.env.QUUB_CERT_FINGERPRINT;
    const actualFingerprint = cert.fingerprint256;

    if (expectedFingerprint !== actualFingerprint) {
      throw new Error("Certificate fingerprint mismatch");
    }
  },
});

const quubClient = new QuubClient({
  apiKey: process.env.QUUB_API_KEY,
  apiSecret: process.env.QUUB_API_SECRET,
  httpsAgent: secureAgent,
});
```

---

## Network Security

### Rate Limiting

```javascript
import rateLimit from "express-rate-limit";

// API endpoint rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  message: "Too many requests from this IP",
  standardHeaders: true,
  legacyHeaders: false,

  // Custom key generator (use user ID if authenticated)
  keyGenerator: (req) => {
    return req.user?.id || req.ip;
  },

  // Skip rate limiting for whitelisted IPs
  skip: (req) => {
    const whitelist = process.env.RATE_LIMIT_WHITELIST.split(",");
    return whitelist.includes(req.ip);
  },
});

app.use("/api/", apiLimiter);

// Stricter rate limit for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: "Too many authentication attempts",
});

app.use("/api/auth/", authLimiter);
```

### DDoS Protection

```javascript
import helmet from "helmet";
import mongoSanitize from "express-mongo-sanitize";
import xss from "xss-clean";

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'", "https://api.quub.fi", "wss://ws.quub.fi"],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  })
);

// Sanitize inputs
app.use(mongoSanitize());
app.use(xss());

// Request size limits
app.use(express.json({ limit: "10kb" }));
app.use(express.urlencoded({ extended: true, limit: "10kb" }));
```

---

## Compliance

### GDPR Compliance

```javascript
class GDPRCompliance {
  // Right to be forgotten
  async deleteUserData(userId) {
    console.log(`🗑️ Deleting data for user ${userId}...`);

    try {
      // 1. Cancel all active orders
      const activeOrders = await quubClient.exchange.getOrders({
        userId,
        status: "open",
      });

      for (const order of activeOrders) {
        await quubClient.exchange.cancelOrder(order.orderId);
      }

      // 2. Close all positions
      const positions = await quubClient.exchange.getPositions({ userId });
      for (const position of positions) {
        await this.closePosition(position.id);
      }

      // 3. Request account deletion from Quub
      await quubClient.identity.deleteAccount(userId);

      // 4. Delete from internal databases
      await this.deleteFromInternalDB(userId);

      // 5. Notify user
      await this.sendDeletionConfirmation(userId);

      console.log(`✅ User data deleted: ${userId}`);
    } catch (error) {
      console.error(`❌ Failed to delete user data: ${error.message}`);
      throw error;
    }
  }

  // Data portability
  async exportUserData(userId) {
    const userData = {
      profile: await quubClient.identity.getUser(userId),
      orders: await this.getAllOrders(userId),
      transactions: await this.getAllTransactions(userId),
      balances: await quubClient.custodian.getBalances({ userId }),
      exportedAt: new Date().toISOString(),
    };

    return userData;
  }
}
```

### AML/KYC Integration

```javascript
class AMLKYCHandler {
  async verifyUser(userData) {
    // Step 1: Identity verification
    const identityResult = await quubClient.identity.verifyIdentity({
      userId: userData.userId,
      firstName: userData.firstName,
      lastName: userData.lastName,
      dateOfBirth: userData.dateOfBirth,
      nationality: userData.nationality,
      documentType: "passport",
      documentNumber: userData.documentNumber,
      documentImage: userData.documentImage,
    });

    if (identityResult.status !== "verified") {
      throw new Error("Identity verification failed");
    }

    // Step 2: AML screening
    const amlResult = await quubClient.compliance.screenAML({
      userId: userData.userId,
      fullName: `${userData.firstName} ${userData.lastName}`,
      dateOfBirth: userData.dateOfBirth,
      nationality: userData.nationality,
    });

    if (amlResult.riskLevel === "high") {
      await this.flagForManualReview(userData.userId, amlResult);
      throw new Error("AML screening flagged user for review");
    }

    // Step 3: Source of funds verification
    await this.verifySourceOfFunds(userData);

    return {
      verified: true,
      verificationId: identityResult.verificationId,
      riskLevel: amlResult.riskLevel,
    };
  }

  async monitorTransactions(transaction) {
    // Real-time transaction monitoring
    const analysis = await quubClient.compliance.analyzeTransaction({
      transactionId: transaction.id,
      userId: transaction.userId,
      amount: transaction.amount,
      currency: transaction.currency,
      type: transaction.type,
      counterparty: transaction.counterparty,
    });

    if (analysis.suspicious) {
      await this.fileSuspiciousActivityReport(transaction, analysis);
    }

    return analysis;
  }
}
```

---

## Incident Response

### Security Incident Detection

```javascript
class SecurityMonitor {
  constructor() {
    this.alertThresholds = {
      failedLogins: 5,
      largeWithdrawal: 100000,
      unusualActivity: 10,
    };
  }

  async monitorFailedLogins(userId) {
    const failures = await this.getRecentFailedLogins(userId);

    if (failures.length >= this.alertThresholds.failedLogins) {
      await this.handleSuspiciousActivity({
        type: "MULTIPLE_FAILED_LOGINS",
        userId,
        count: failures.length,
        severity: "high",
      });
    }
  }

  async monitorWithdrawals(withdrawal) {
    const amount = parseFloat(withdrawal.amount);
    const userProfile = await this.getUserProfile(withdrawal.userId);

    // Check if withdrawal is unusually large
    if (amount > userProfile.averageWithdrawal * 10) {
      await this.handleSuspiciousActivity({
        type: "UNUSUAL_WITHDRAWAL",
        userId: withdrawal.userId,
        amount,
        averageAmount: userProfile.averageWithdrawal,
        severity: "high",
      });
    }

    // Require additional verification
    if (amount > this.alertThresholds.largeWithdrawal) {
      return this.requestAdditionalVerification(withdrawal);
    }
  }

  async handleSuspiciousActivity(incident) {
    // Log incident
    logger.warn("Security Incident", incident);

    // Lock account if severe
    if (incident.severity === "high") {
      await quubClient.identity.lockAccount(incident.userId);
    }

    // Alert security team
    await this.alertSecurityTeam(incident);

    // Notify user
    await this.notifyUser(incident.userId, incident.type);
  }
}
```

### Incident Response Plan

```javascript
class IncidentResponsePlan {
  async handleSecurityBreach(breachDetails) {
    console.log("🚨 SECURITY BREACH DETECTED");

    // Phase 1: Containment
    await this.containBreach(breachDetails);

    // Phase 2: Investigation
    const investigation = await this.investigateBreach(breachDetails);

    // Phase 3: Remediation
    await this.remediateBreach(investigation);

    // Phase 4: Communication
    await this.communicateBreach(investigation);

    // Phase 5: Post-incident review
    await this.postIncidentReview(investigation);
  }

  async containBreach(details) {
    // 1. Revoke all API keys
    await quubClient.auth.revokeAllApiKeys();

    // 2. Lock affected accounts
    for (const userId of details.affectedUsers) {
      await quubClient.identity.lockAccount(userId);
    }

    // 3. Enable IP whitelist
    await quubClient.auth.updateSecuritySettings({
      enforceWhitelist: true,
    });

    // 4. Rotate encryption keys
    await this.rotateEncryptionKeys();

    console.log("✅ Breach contained");
  }
}
```

---

## Security Checklist

### Pre-Production Checklist

- [ ] **API Key Management**

  - [ ] Keys stored in secure secret manager
  - [ ] Keys never committed to version control
  - [ ] Separate keys for dev/staging/production
  - [ ] API keys use minimal required scopes
  - [ ] Key rotation schedule configured

- [ ] **Authentication**

  - [ ] MFA enabled for all admin accounts
  - [ ] JWT tokens expire within 1 hour
  - [ ] Refresh token rotation implemented
  - [ ] Session management configured
  - [ ] IP whitelist configured

- [ ] **Data Protection**

  - [ ] Sensitive data encrypted at rest
  - [ ] TLS 1.2+ enforced
  - [ ] Certificate pinning implemented
  - [ ] PII data properly masked in logs
  - [ ] Data retention policy configured

- [ ] **Network Security**

  - [ ] Rate limiting enabled
  - [ ] DDoS protection configured
  - [ ] Security headers set (Helmet.js)
  - [ ] Input validation on all endpoints
  - [ ] CORS properly configured

- [ ] **Monitoring**
  - [ ] Failed login attempts monitored
  - [ ] Unusual activity alerts configured
  - [ ] Security logs centralized
  - [ ] Incident response plan documented
  - [ ] Regular security audits scheduled

---

## Next Steps

- **[Compliance Guide](../compliance/)** - Regulatory compliance
- **[Incident Response](../incident-response/)** - Handle security incidents
- **[Best Practices](../best-practices/)** - General development best practices

---

**Security Concerns?** Contact security@quub.fi | Report vulnerabilities to security-reports@quub.fi
