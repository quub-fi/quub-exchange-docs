# Use Cases Documentation

This directory contains detailed documentation for all major use cases and workflows in the Quub Exchange platform.

## 📋 Overview

Comprehensive documentation covering business logic, technical implementations, and security patterns for the exchange platform.

## 📁 Directory Structure

### Authentication & Authorization

- [`auth/`](./auth/) - Complete authentication system documentation
  - **JWT Implementation**: Token lifecycle, validation, and multi-tenant security
  - **Authorization Patterns**: Role-based access control and tenant isolation
  - **Security Architecture**: Database RLS, token management, and revocation
  - **Testing Strategies**: Unit, integration, E2E, and contract testing

### Trading Operations

- _[Trading use cases to be documented]_

### Account Management

- _[Account management use cases to be documented]_

### Compliance & Reporting

- _[Compliance use cases to be documented]_

## 🔐 Security-First Design

All use cases prioritize security and multi-tenant isolation:

| Security Layer     | Implementation                | Documentation                                                            |
| ------------------ | ----------------------------- | ------------------------------------------------------------------------ |
| **Authentication** | JWT with org-scoped claims    | [JWT Documentation](./auth/JWT/)                                         |
| **Authorization**  | Role-based + tenant isolation | [Auth Overview](./auth/)                                                 |
| **Data Isolation** | Database RLS by orgId         | [JWT Validation Flow](./auth/JWT/jwt-validation-authorization-flow.poml) |
| **Token Security** | Rotation + revocation         | [JWT Lifecycle](./auth/JWT/jwt-lifecycle-flow.poml)                      |

## 🚀 Quick Start

### For New Developers

1. Start with [Authentication Overview](./auth/)
2. Review [JWT Fundamentals](./auth/JWT/JWT101.md)
3. Study the [JWT Lifecycle](./auth/JWT/jwt-lifecycle-flow.poml)
4. Implement following [Testing Strategy](./auth/JWT/jwt-testing-strategy.poml)

### For Architecture Review

```bash
# View all system diagrams
find . -name "diagrams" -type d -exec open {}/*.svg \;

# Or view specific auth diagrams
open auth/JWT/diagrams/*.svg
```

## 📊 Documentation Standards

### PlantUML Diagrams

- All workflows documented with PlantUML (`.poml` files)
- SVG renders generated for easy viewing
- Consistent naming: `kebab-case.poml`

### Content Structure

- **README.md**: Overview and navigation
- **Technical docs**: Implementation details
- **Diagrams**: Visual workflow representations
- **Examples**: Code snippets and configurations

## 🧪 Testing Documentation

Each use case includes comprehensive testing strategies:

- **Unit Tests**: Component-level validation
- **Integration Tests**: Service interaction testing
- **E2E Tests**: Complete workflow validation
- **Contract Tests**: API consistency verification

---

_All use cases are designed with security, scalability, and maintainability as core principles._
