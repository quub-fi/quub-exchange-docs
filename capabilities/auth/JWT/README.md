# JWT Authentication & Authorization

This directory contains comprehensive documentation for JWT (JSON Web Token) implementation in the Quub Exchange platform, focusing on secure authentication, authorization, and multi-tenant isolation.

## 📋 Overview

Our JWT implementation provides:

- **Secure Authentication**: Login/logout with access and refresh tokens
- **Multi-tenant Authorization**: Organization-level isolation using Row Level Security (RLS)
- **Token Lifecycle Management**: Issue, use, refresh, and revoke tokens
- **Comprehensive Testing Strategy**: From unit tests to end-to-end validation

## 📁 Documentation Structure

### PlantUML Diagrams

- [`jwt-lifecycle-flow.poml`](./jwt-lifecycle-flow.poml) - Complete token lifecycle from login to logout
- [`jwt-validation-authorization-flow.poml`](./jwt-validation-authorization-flow.poml) - Validation and authorization patterns
- [`jwt-testing-strategy.poml`](./jwt-testing-strategy.poml) - Testing strategy across all levels

### Generated Diagrams

- [`diagrams/`](./diagrams/) - SVG renders of all PlantUML diagrams for easy viewing

### Educational Content

- [`JWT101.md`](./JWT101.md) - Fundamentals and best practices

## 🔄 JWT Lifecycle

```
Login → Issue Tokens → Use Access Token → Refresh When Expired → Logout/Revoke
```

### Key Components

1. **Auth Service** (Fastify + JWT) - Issues and validates tokens
2. **Exchange API** - Consumes tokens for authorization
3. **Database** - Row Level Security (RLS) for tenant isolation
4. **Revocation List** - Cache for blacklisted tokens

## 🔐 Security Features

### Multi-tenant Isolation

- **Organization ID in JWT claims**: `{userId, orgId, roles}`
- **URL validation**: Ensures `orgId` in URL matches JWT claims
- **Database RLS**: Automatic tenant isolation at data layer
- **App context**: `app.orgId = JWT.orgId` for all queries

### Token Management

- **Short-lived access tokens**: Minimize exposure window
- **Long-lived refresh tokens**: Reduce login friction
- **Token rotation**: Fresh tokens on each refresh
- **Revocation support**: Immediate logout capability

## 🧪 Testing Strategy

Our comprehensive testing approach covers:

### Unit Tests

- JWT creation, validation, and parsing
- Claims extraction and validation
- Token expiry handling

### Integration Tests

- Auth service endpoints
- Database RLS validation
- Cache/revocation list operations

### End-to-End Tests

- Complete user authentication flows
- Cross-service token validation
- Multi-tenant isolation verification

### Contract Tests

- API contract validation
- Token format consistency
- Error response standardization

## 🚀 Quick Start

### Viewing Diagrams

```bash
# Generate SVG diagrams
plantuml -tsvg -o ./diagrams *.poml

# Open diagrams
open diagrams/*.svg
```

### Implementation Reference

```javascript
// JWT Claims Structure
{
  "userId": "user_123",
  "orgId": "org_456",
  "roles": ["admin", "trader"],
  "iat": 1699123456,
  "exp": 1699127056
}
```

## 📚 Related Documentation

- [Authentication API Documentation](../api-documentation/)
- [Authentication Overview](../README.md)
- [OpenAPI Specification](../../../openapi/auth.yaml)

## 🔧 Development Tools

- **PlantUML**: Diagram generation
- **Fastify**: Auth service framework
- **JWT Libraries**: Token creation and validation
- **Testing Frameworks**: Comprehensive test coverage

---

_For detailed implementation guides and best practices, see the individual files and diagrams in this directory._
