---
layout: docs
title: Authentication Service Guides
permalink: /capabilities/auth/guides/
---

# 📚 Authentication Service Implementation Guides

> Comprehensive developer guide for implementing secure authentication, user registration, and session management.

## 🚀 Quick Navigation

<div class="nav-cards">
  <div class="nav-card">
    <h3><a href="#quick-start">🎯 Getting Started</a></h3>
    <p>5-minute setup with login, registration, and session management</p>
  </div>
  <div class="nav-card">
    <h3><a href="#core-operations">🏗️ Core Operations</a></h3>
    <p>User authentication, registration, and password management</p>
  </div>
  <div class="nav-card">
    <h3><a href="#best-practices">✨ Best Practices</a></h3>
    <p>Security guidelines, error handling, and performance optimization</p>
  </div>
</div>

## 🎯 API Overview & Architecture {#overview}

### Business Purpose

- **Secure Authentication**: Email/password login with JWT token management
- **User Registration**: Account creation with email and password validation
- **Session Management**: Token-based authentication with refresh capabilities
- **Password Security**: Secure password change with current password verification
- **User Profile Access**: Retrieve authenticated user account information

### Technical Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Client App    │───▶│   Auth Service   │───▶│   User Store    │
│                 │    │                  │    │                 │
│ • Login         │    │ • Authentication │    │ • Accounts      │
│ • Registration  │    │ • Session Mgmt   │    │ • Credentials   │
│ • Password Mgmt │    │ • Token Issuance │    │ • Sessions      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   JWT Tokens     │
                       │                  │
                       │ • Access Token   │
                       │ • Refresh Token  │
                       │ • Expiration     │
                       └──────────────────┘
```

### Core Data Models

**AuthSession Schema:**

```json
{
  "account": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "string",
    "lastName": "string"
  },
  "token": "JWT_ACCESS_TOKEN",
  "refreshToken": "JWT_REFRESH_TOKEN",
  "expiresAt": "2024-12-01T10:30:00Z"
}
```

## 🎯 Quick Start {#quick-start}

### Prerequisites

- **API Access**: Quub Exchange API credentials
- **HTTPS Client**: For secure authentication calls
- **JWT Handling**: Library for token parsing and validation

### 5-Minute Setup

**Step 1: User Registration**

```javascript
// Node.js Example
const registerUser = async (email, password, firstName, lastName) => {
  const response = await fetch("https://api.quub.exchange/v2/auth/register", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      password,
      firstName,
      lastName,
    }),
  });

  const result = await response.json();
  return result.data; // Returns AuthSession
};
```

```python
# Python Example
import requests

def register_user(email, password, first_name=None, last_name=None):
    payload = {
        "email": email,
        "password": password
    }
    if first_name:
        payload["firstName"] = first_name
    if last_name:
        payload["lastName"] = last_name

    response = requests.post(
        'https://api.quub.exchange/v2/auth/register',
        json=payload
    )

    if response.status_code == 201:
        return response.json()['data']
    else:
        response.raise_for_status()
```

**Step 2: User Authentication**

```javascript
// Node.js Login
const loginUser = async (email, password) => {
  const response = await fetch("https://api.quub.exchange/v2/auth/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      password,
    }),
  });

  const result = await response.json();
  const session = result.data;

  // Store tokens securely
  localStorage.setItem("accessToken", session.token);
  localStorage.setItem("refreshToken", session.refreshToken);

  return session;
};
```

```python
# Python Login
def login_user(email, password):
    response = requests.post(
        'https://api.quub.exchange/v2/auth/login',
        json={
            "email": email,
            "password": password
        }
    )

    if response.status_code == 200:
        session = response.json()['data']
        # Store tokens securely (use keyring or secure storage)
        return session
    else:
        response.raise_for_status()
```

**Step 3: Access Protected Resources**

```javascript
// Node.js Authenticated Request
const getCurrentUser = async () => {
  const token = localStorage.getItem("accessToken");

  const response = await fetch("https://api.quub.exchange/v2/auth/me", {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  const result = await response.json();
  return result.data; // Returns Account object
};
```

## 🏗️ Core API Operations {#core-operations}

### User Registration

Register new user accounts with email validation.

**Endpoint:** `POST /auth/register`

```javascript
// Complete Registration Example
const registerNewUser = async (userData) => {
  try {
    const response = await fetch("https://api.quub.exchange/v2/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: userData.email,
        password: userData.password,
        firstName: userData.firstName, // Optional
        lastName: userData.lastName, // Optional
      }),
    });

    if (response.status === 201) {
      const result = await response.json();
      console.log("Registration successful:", result.data);
      return result.data;
    } else if (response.status === 409) {
      throw new Error("Email already registered");
    } else {
      throw new Error("Registration failed");
    }
  } catch (error) {
    console.error("Registration error:", error);
    throw error;
  }
};
```

### User Authentication

Authenticate users and establish sessions.

**Endpoint:** `POST /auth/login`

```python
# Complete Login with Error Handling
def authenticate_user(email, password):
    try:
        response = requests.post(
            'https://api.quub.exchange/v2/auth/login',
            json={
                "email": email,
                "password": password
            }
        )

        if response.status_code == 200:
            session_data = response.json()['data']
            print(f"Login successful for user: {session_data['account']['email']}")
            return session_data
        elif response.status_code == 401:
            raise ValueError("Invalid email or password")
        else:
            response.raise_for_status()

    except requests.exceptions.RequestException as e:
        print(f"Login request failed: {e}")
        raise
```

### Session Management

Manage user sessions and logout.

**Endpoint:** `POST /auth/logout`

```javascript
// Logout with Session ID
const logoutUser = async (sessionId) => {
  try {
    const token = localStorage.getItem("accessToken");

    const response = await fetch("https://api.quub.exchange/v2/auth/logout", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        sessionId: sessionId, // Optional - current session if not provided
      }),
    });

    if (response.status === 200) {
      // Clear local tokens
      localStorage.removeItem("accessToken");
      localStorage.removeItem("refreshToken");

      const result = await response.json();
      return result.data.success;
    }
  } catch (error) {
    console.error("Logout error:", error);
    throw error;
  }
};
```

### User Profile Access

Retrieve current authenticated user information.

**Endpoint:** `GET /auth/me`

```python
# Get Current User Profile
def get_current_user(access_token):
    try:
        response = requests.get(
            'https://api.quub.exchange/v2/auth/me',
            headers={
                'Authorization': f'Bearer {access_token}'
            }
        )

        if response.status_code == 200:
            user_data = response.json()['data']
            return user_data
        elif response.status_code == 401:
            raise ValueError("Invalid or expired token")
        elif response.status_code == 404:
            raise ValueError("User not found")
        else:
            response.raise_for_status()

    except requests.exceptions.RequestException as e:
        print(f"Failed to get user profile: {e}")
        raise
```

### Password Management

Change user passwords securely.

**Endpoint:** `POST /auth/password/change`

```javascript
// Change Password
const changePassword = async (currentPassword, newPassword) => {
  try {
    const token = localStorage.getItem("accessToken");

    const response = await fetch(
      "https://api.quub.exchange/v2/auth/password/change",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          currentPassword,
          newPassword,
        }),
      }
    );

    if (response.status === 200) {
      const result = await response.json();
      console.log("Password changed successfully");
      return result.data.success;
    } else if (response.status === 401) {
      throw new Error("Current password is incorrect");
    } else {
      throw new Error("Password change failed");
    }
  } catch (error) {
    console.error("Password change error:", error);
    throw error;
  }
};
```

## 🔐 Authentication Setup {#authentication}

### JWT Token Management

```javascript
// Token Utility Functions
class AuthManager {
  constructor() {
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;
  }

  setTokens(authSession) {
    this.accessToken = authSession.token;
    this.refreshToken = authSession.refreshToken;
    this.tokenExpiry = new Date(authSession.expiresAt);

    // Store securely
    localStorage.setItem("accessToken", this.accessToken);
    localStorage.setItem("refreshToken", this.refreshToken);
    localStorage.setItem("tokenExpiry", this.tokenExpiry.toISOString());
  }

  isTokenExpired() {
    if (!this.tokenExpiry) return true;
    return new Date() >= this.tokenExpiry;
  }

  getAuthHeaders() {
    if (this.isTokenExpired()) {
      throw new Error("Token expired - refresh required");
    }

    return {
      Authorization: `Bearer ${this.accessToken}`,
    };
  }

  clearTokens() {
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;

    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("tokenExpiry");
  }
}
```

### API Key Authentication

```python
# API Key Usage (Alternative to JWT)
class QuubAuthClient:
    def __init__(self, api_key=None):
        self.api_key = api_key
        self.base_url = 'https://api.quub.exchange/v2'

    def get_headers(self):
        if self.api_key:
            return {'X-API-Key': self.api_key}
        return {}

    def make_authenticated_request(self, method, endpoint, **kwargs):
        headers = self.get_headers()
        if 'headers' in kwargs:
            headers.update(kwargs['headers'])
        kwargs['headers'] = headers

        url = f"{self.base_url}{endpoint}"
        response = requests.request(method, url, **kwargs)
        return response
```

## ✨ Best Practices {#best-practices}

### Error Handling

```javascript
// Comprehensive Error Handling
const handleAuthError = (error, response) => {
  switch (response?.status) {
    case 400:
      return "Invalid request data - check email format and password requirements";
    case 401:
      return "Authentication failed - invalid credentials or expired token";
    case 404:
      return "User not found - check account exists";
    case 409:
      return "Email already registered - use different email or login";
    case 500:
      return "Server error - please try again later";
    default:
      return error.message || "Unknown authentication error";
  }
};

// Usage in registration
const safeRegister = async (userData) => {
  try {
    return await registerNewUser(userData);
  } catch (error) {
    const userMessage = handleAuthError(error, error.response);
    console.error("Registration failed:", userMessage);
    throw new Error(userMessage);
  }
};
```

### Input Validation

```python
# Input Validation for Authentication
import re

class AuthValidator:
    @staticmethod
    def validate_email(email):
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, email):
            raise ValueError("Invalid email format")
        return True

    @staticmethod
    def validate_password(password):
        if len(password) < 8:
            raise ValueError("Password must be at least 8 characters long")
        if not re.search(r'[A-Za-z]', password):
            raise ValueError("Password must contain at least one letter")
        if not re.search(r'\d', password):
            raise ValueError("Password must contain at least one number")
        return True

    @staticmethod
    def validate_registration_data(email, password, first_name=None, last_name=None):
        AuthValidator.validate_email(email)
        AuthValidator.validate_password(password)

        if first_name and len(first_name.strip()) == 0:
            raise ValueError("First name cannot be empty")
        if last_name and len(last_name.strip()) == 0:
            raise ValueError("Last name cannot be empty")

        return True
```

### Rate Limiting

```javascript
// Rate Limiting for Authentication Calls
class AuthRateLimiter {
  constructor() {
    this.attempts = new Map();
    this.maxAttempts = 5;
    this.windowMs = 15 * 60 * 1000; // 15 minutes
  }

  canAttempt(identifier) {
    const now = Date.now();
    const attempts = this.attempts.get(identifier) || [];

    // Remove old attempts
    const validAttempts = attempts.filter((time) => now - time < this.windowMs);
    this.attempts.set(identifier, validAttempts);

    return validAttempts.length < this.maxAttempts;
  }

  recordAttempt(identifier) {
    const attempts = this.attempts.get(identifier) || [];
    attempts.push(Date.now());
    this.attempts.set(identifier, attempts);
  }

  getRemainingAttempts(identifier) {
    const attempts = this.attempts.get(identifier) || [];
    const validAttempts = attempts.filter(
      (time) => Date.now() - time < this.windowMs
    );
    return Math.max(0, this.maxAttempts - validAttempts.length);
  }
}
```

## 🔒 Security Guidelines {#security}

### Token Security

```javascript
// Secure Token Storage and Handling
class SecureTokenManager {
  constructor() {
    this.tokenKey = "quub_auth_token";
    this.refreshKey = "quub_refresh_token";
  }

  // Use secure storage (not localStorage in production)
  storeTokens(authSession) {
    // In production, use secure storage like:
    // - iOS: Keychain Services
    // - Android: EncryptedSharedPreferences
    // - Web: Secure HttpOnly cookies

    const expiryTime = new Date(authSession.expiresAt).getTime();
    const tokenData = {
      token: authSession.token,
      refreshToken: authSession.refreshToken,
      expiresAt: expiryTime,
      storedAt: Date.now(),
    };

    // Encrypt before storing (use crypto library)
    const encryptedData = this.encrypt(JSON.stringify(tokenData));
    localStorage.setItem(this.tokenKey, encryptedData);
  }

  encrypt(data) {
    // Implement proper encryption
    // For demo purposes only - use proper crypto library
    return btoa(data);
  }

  decrypt(encryptedData) {
    // Implement proper decryption
    return atob(encryptedData);
  }

  getTokens() {
    try {
      const encryptedData = localStorage.getItem(this.tokenKey);
      if (!encryptedData) return null;

      const decryptedData = this.decrypt(encryptedData);
      const tokenData = JSON.parse(decryptedData);

      // Check if token is expired
      if (Date.now() >= tokenData.expiresAt) {
        this.clearTokens();
        return null;
      }

      return tokenData;
    } catch (error) {
      console.error("Token retrieval error:", error);
      this.clearTokens();
      return null;
    }
  }

  clearTokens() {
    localStorage.removeItem(this.tokenKey);
  }
}
```

### Password Security

```python
# Password Security Best Practices
import hashlib
import secrets
import base64

class PasswordSecurity:
    @staticmethod
    def generate_secure_password(length=16):
        """Generate a cryptographically secure password"""
        alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        password = ''.join(secrets.choice(alphabet) for _ in range(length))
        return password

    @staticmethod
    def hash_password_client_side(password, salt=None):
        """Client-side password hashing before transmission"""
        if salt is None:
            salt = secrets.token_bytes(32)

        # Use PBKDF2 for client-side hashing
        hashed = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
        return base64.b64encode(salt + hashed).decode()

    @staticmethod
    def validate_password_strength(password):
        """Validate password meets security requirements"""
        errors = []

        if len(password) < 8:
            errors.append("Password must be at least 8 characters long")
        if len(password) > 128:
            errors.append("Password must be no more than 128 characters long")
        if not re.search(r'[a-z]', password):
            errors.append("Password must contain at least one lowercase letter")
        if not re.search(r'[A-Z]', password):
            errors.append("Password must contain at least one uppercase letter")
        if not re.search(r'\d', password):
            errors.append("Password must contain at least one digit")
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            errors.append("Password must contain at least one special character")

        return len(errors) == 0, errors
```

## 🚀 Performance Optimization {#performance}

### Caching Strategies

```javascript
// Token Caching and Management
class TokenCache {
  constructor() {
    this.cache = new Map();
    this.maxCacheSize = 100;
    this.defaultTtl = 3600000; // 1 hour
  }

  set(key, token, ttl = this.defaultTtl) {
    const expiryTime = Date.now() + ttl;
    this.cache.set(key, { token, expiryTime });

    // Cleanup if cache is too large
    if (this.cache.size > this.maxCacheSize) {
      this.cleanup();
    }
  }

  get(key) {
    const entry = this.cache.get(key);
    if (!entry) return null;

    if (Date.now() >= entry.expiryTime) {
      this.cache.delete(key);
      return null;
    }

    return entry.token;
  }

  cleanup() {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (now >= entry.expiryTime) {
        this.cache.delete(key);
      }
    }
  }

  clear() {
    this.cache.clear();
  }
}
```

### Request Batching

```python
# Batch Authentication Requests
import asyncio
import aiohttp

class BatchAuthClient:
    def __init__(self, base_url='https://api.quub.exchange/v2'):
        self.base_url = base_url
        self.session = None

    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    async def batch_user_lookups(self, user_tokens):
        """Batch multiple user profile lookups"""
        tasks = []
        for token in user_tokens:
            task = self.get_user_profile(token)
            tasks.append(task)

        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results

    async def get_user_profile(self, token):
        async with self.session.get(
            f"{self.base_url}/auth/me",
            headers={'Authorization': f'Bearer {token}'}
        ) as response:
            if response.status == 200:
                data = await response.json()
                return data['data']
            else:
                return None
```

## 🔧 Advanced Configuration {#advanced}

### Multi-Environment Setup

```javascript
// Environment-Specific Configuration
class AuthConfig {
  constructor(environment = "production") {
    this.configs = {
      production: {
        baseUrl: "https://api.quub.exchange/v2",
        tokenExpiry: 3600000, // 1 hour
        refreshThreshold: 300000, // 5 minutes
        maxRetries: 3,
      },
      sandbox: {
        baseUrl: "https://api.sandbox.quub.exchange/v2",
        tokenExpiry: 7200000, // 2 hours
        refreshThreshold: 600000, // 10 minutes
        maxRetries: 5,
      },
      development: {
        baseUrl: "http://localhost:8080/v2",
        tokenExpiry: 86400000, // 24 hours
        refreshThreshold: 3600000, // 1 hour
        maxRetries: 1,
      },
    };

    this.env = environment;
  }

  get() {
    return this.configs[this.env] || this.configs.production;
  }

  getEndpoint(path) {
    return `${this.get().baseUrl}${path}`;
  }
}

// Usage
const authConfig = new AuthConfig("sandbox");
const loginUrl = authConfig.getEndpoint("/auth/login");
```

### Custom Authentication Flow

```python
# Custom Authentication Workflow
class CustomAuthFlow:
    def __init__(self, config):
        self.config = config
        self.current_user = None
        self.session_data = None

    async def authenticate_with_retry(self, email, password, max_retries=3):
        """Authenticate with automatic retry on temporary failures"""
        for attempt in range(max_retries):
            try:
                session = await self.login(email, password)
                self.session_data = session
                self.current_user = session['account']
                return session
            except requests.exceptions.RequestException as e:
                if attempt == max_retries - 1:
                    raise
                await asyncio.sleep(2 ** attempt)  # Exponential backoff

    async def auto_refresh_token(self):
        """Automatically refresh token when near expiry"""
        if not self.session_data:
            return False

        expiry = datetime.fromisoformat(self.session_data['expiresAt'])
        time_to_expiry = expiry - datetime.now()

        # Refresh if less than 5 minutes remaining
        if time_to_expiry.total_seconds() < 300:
            try:
                # Implementation would depend on refresh token endpoint
                # Note: Current API spec doesn't include refresh endpoint
                return await self.refresh_session()
            except Exception as e:
                print(f"Token refresh failed: {e}")
                return False

        return True

    async def logout_all_sessions(self):
        """Logout from all sessions"""
        if self.session_data:
            await self.logout()
            self.session_data = None
            self.current_user = None
```

## 🔍 Troubleshooting {#troubleshooting}

### Common Issues and Solutions

**Issue: Login fails with 401 Unauthorized**

```javascript
// Debug Authentication Issues
const debugLogin = async (email, password) => {
  console.log("Attempting login for:", email);

  try {
    const response = await fetch("https://api.quub.exchange/v2/auth/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });

    console.log("Response status:", response.status);
    console.log("Response headers:", Object.fromEntries(response.headers));

    const result = await response.json();
    console.log("Response body:", result);

    if (!response.ok) {
      switch (response.status) {
        case 400:
          console.error("Bad Request - Check email format and password");
          break;
        case 401:
          console.error("Unauthorized - Invalid credentials");
          break;
        case 500:
          console.error("Server Error - Try again later");
          break;
        default:
          console.error("Unexpected error:", response.status);
      }
    }

    return result;
  } catch (error) {
    console.error("Network error:", error);
    throw error;
  }
};
```

**Issue: Token expires unexpectedly**

```python
# Token Expiry Debugging
import jwt
from datetime import datetime

def debug_token_expiry(token):
    try:
        # Decode without verification to inspect claims
        decoded = jwt.decode(token, options={"verify_signature": False})

        exp_timestamp = decoded.get('exp')
        if exp_timestamp:
            exp_datetime = datetime.fromtimestamp(exp_timestamp)
            current_time = datetime.now()

            print(f"Token expires at: {exp_datetime}")
            print(f"Current time: {current_time}")
            print(f"Time remaining: {exp_datetime - current_time}")

            if exp_datetime <= current_time:
                print("❌ Token has expired")
                return False
            else:
                print("✅ Token is still valid")
                return True
        else:
            print("⚠️ No expiry claim found in token")
            return None

    except jwt.DecodeError:
        print("❌ Invalid token format")
        return False
```

**Issue: Registration fails with 409 Conflict**

```javascript
// Handle Registration Conflicts
const handleRegistrationConflict = async (email, password) => {
  try {
    await registerNewUser({ email, password });
  } catch (error) {
    if (
      error.message.includes("409") ||
      error.message.includes("already registered")
    ) {
      console.log("Email already exists, attempting login instead");
      try {
        return await loginUser(email, password);
      } catch (loginError) {
        throw new Error(
          "Email already registered but login failed - please reset password"
        );
      }
    }
    throw error;
  }
};
```

### Performance Diagnostics

```python
# Performance Monitoring for Auth Operations
import time
import functools

def monitor_auth_performance(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()

        try:
            result = func(*args, **kwargs)
            success = True
        except Exception as e:
            result = None
            success = False
            print(f"Auth operation failed: {e}")
            raise
        finally:
            end_time = time.time()
            duration = end_time - start_time

            print(f"Auth operation '{func.__name__}' took {duration:.2f}s")

            if duration > 5.0:  # Slow operation threshold
                print(f"⚠️ Slow auth operation detected: {duration:.2f}s")

            # Log to monitoring system
            log_auth_metrics(func.__name__, duration, success)

        return result
    return wrapper

def log_auth_metrics(operation, duration, success):
    # Send metrics to monitoring system
    metrics = {
        'operation': operation,
        'duration_ms': duration * 1000,
        'success': success,
        'timestamp': time.time()
    }
    print(f"Auth metrics: {metrics}")
```

## 📊 Monitoring & Observability {#monitoring}

### Metrics Collection

```javascript
// Authentication Metrics
class AuthMetrics {
  constructor() {
    this.metrics = {
      loginAttempts: 0,
      loginSuccesses: 0,
      loginFailures: 0,
      registrations: 0,
      passwordChanges: 0,
      tokenRefreshes: 0,
    };
  }

  recordLogin(success) {
    this.metrics.loginAttempts++;
    if (success) {
      this.metrics.loginSuccesses++;
    } else {
      this.metrics.loginFailures++;
    }
    this.sendMetrics("auth.login", { success });
  }

  recordRegistration() {
    this.metrics.registrations++;
    this.sendMetrics("auth.registration", {});
  }

  recordPasswordChange() {
    this.metrics.passwordChanges++;
    this.sendMetrics("auth.password_change", {});
  }

  getLoginSuccessRate() {
    if (this.metrics.loginAttempts === 0) return 0;
    return (this.metrics.loginSuccesses / this.metrics.loginAttempts) * 100;
  }

  sendMetrics(event, data) {
    // Send to monitoring service
    console.log(`Metric: ${event}`, {
      ...data,
      timestamp: new Date().toISOString(),
    });
  }

  generateReport() {
    return {
      ...this.metrics,
      successRate: this.getLoginSuccessRate(),
      timestamp: new Date().toISOString(),
    };
  }
}
```

### Logging Strategy

```python
# Structured Logging for Authentication
import logging
import json
from datetime import datetime

class AuthLogger:
    def __init__(self):
        self.logger = logging.getLogger('quub.auth')
        self.logger.setLevel(logging.INFO)

        # Create console handler with JSON formatter
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)

    def log_auth_event(self, event_type, user_id=None, email=None, success=True, error=None, **extra):
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'success': success,
            'user_id': user_id,
            'email': email,
            'error': str(error) if error else None,
            **extra
        }

        # Remove None values
        log_data = {k: v for k, v in log_data.items() if v is not None}

        level = logging.INFO if success else logging.ERROR
        self.logger.log(level, json.dumps(log_data))

    def log_login(self, email, success, error=None, ip_address=None):
        self.log_auth_event('login', email=email, success=success,
                          error=error, ip_address=ip_address)

    def log_registration(self, email, success, error=None):
        self.log_auth_event('registration', email=email, success=success, error=error)

    def log_password_change(self, user_id, success, error=None):
        self.log_auth_event('password_change', user_id=user_id,
                          success=success, error=error)

    def log_logout(self, user_id, session_id=None):
        self.log_auth_event('logout', user_id=user_id,
                          session_id=session_id, success=True)

# Usage
auth_logger = AuthLogger()
auth_logger.log_login('user@example.com', success=True, ip_address='192.168.1.1')
```

### Health Checks

```javascript
// Authentication Service Health Check
class AuthHealthChecker {
  constructor(config) {
    this.config = config;
    this.lastCheck = null;
    this.status = "unknown";
  }

  async checkHealth() {
    const healthCheck = {
      timestamp: new Date().toISOString(),
      service: "auth",
      status: "healthy",
      checks: {},
    };

    try {
      // Test basic connectivity
      const connectivityCheck = await this.checkConnectivity();
      healthCheck.checks.connectivity = connectivityCheck;

      // Test auth endpoint availability
      const endpointCheck = await this.checkEndpoints();
      healthCheck.checks.endpoints = endpointCheck;

      // Overall health status
      const allChecksHealthy = Object.values(healthCheck.checks).every(
        (check) => check.status === "healthy"
      );

      healthCheck.status = allChecksHealthy ? "healthy" : "unhealthy";
    } catch (error) {
      healthCheck.status = "unhealthy";
      healthCheck.error = error.message;
    }

    this.lastCheck = healthCheck;
    this.status = healthCheck.status;

    return healthCheck;
  }

  async checkConnectivity() {
    try {
      const response = await fetch(`${this.config.baseUrl}/health`, {
        method: "GET",
        timeout: 5000,
      });

      return {
        status: response.ok ? "healthy" : "unhealthy",
        responseTime: Date.now(),
        statusCode: response.status,
      };
    } catch (error) {
      return {
        status: "unhealthy",
        error: error.message,
      };
    }
  }

  async checkEndpoints() {
    const endpoints = [
      { path: "/auth/login", method: "POST" },
      { path: "/auth/register", method: "POST" },
      { path: "/auth/me", method: "GET" },
    ];

    const results = {};

    for (const endpoint of endpoints) {
      try {
        const start = Date.now();
        const response = await fetch(`${this.config.baseUrl}${endpoint.path}`, {
          method: "HEAD", // Use HEAD to avoid side effects
          timeout: 3000,
        });
        const duration = Date.now() - start;

        results[endpoint.path] = {
          status: response.status < 500 ? "healthy" : "unhealthy",
          responseTime: duration,
          statusCode: response.status,
        };
      } catch (error) {
        results[endpoint.path] = {
          status: "unhealthy",
          error: error.message,
        };
      }
    }

    return results;
  }
}
```

## 📚 Additional Resources

### API Documentation

- [Authentication API Reference](../api-reference/) - Complete API specification
- [OpenAPI Specification](../../openapi/auth.yaml) - Machine-readable API definition

### Integration Guides

- [Getting Started Guide](../../docs/quickstart/) - Platform setup and first API calls
- [Authentication Setup](../../docs/authentication/) - JWT and API key configuration

### Security Resources

- [Security Best Practices](../../docs/best-practices/) - Security implementation guidelines
- [Rate Limiting](../../docs/rate-limits/) - API rate limiting and throttling

### Example Applications

- [Node.js Auth Example](../../examples/nodejs-auth/) - Complete Node.js integration
- [Python Auth Example](../../examples/python-auth/) - Complete Python integration
- [React Auth Flow](../../examples/react-auth/) - Frontend authentication patterns

---

_Secure authentication and session management for the Quub Exchange platform._
