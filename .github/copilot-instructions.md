# API Documentation Agent Instructions

## Objective

Create comprehensive API documentation for each Quub Exchange service following the established template and format.

---

## Template Structure

Each API documentation file must include the following sections **in order**:

---

### 1. Header

- Title: `{Service Name} API Documentation`
- Subtitle: `_Based on OpenAPI specification: {service-name}.yaml_`

---

### 2. Executive Summary

**Audience:** Stakeholders

- Business value proposition
- Key capabilities and strategic importance

---

### 3. Service Overview

**Audience:** All

- **Business Purpose**: 5–7 bullet points
- **Technical Architecture**: 5–7 bullet points

---

### 4. API Specifications

**Audience:** Technical

- Base Configuration (YAML format)
- Authentication & Authorization details

---

### 5. Core Endpoints

**Audience:** Technical + Project Teams
Group endpoints by functional area.
For **each** endpoint include:

- HTTP method + path
- Business Use Case description
- Request Example (JSON)
- Response Example (JSON)
- 4–5 Project Implementation Notes

---

### 6. Security Implementation

**Audience:** Technical + Project Teams

- Multi-tenant Isolation (YAML example)
- Data Protection measures
- Access Controls (JSON example)

---

### 7. Business Workflows

**Audience:** Stakeholders + Project Teams

- **Primary Workflow** — Mermaid diagram + description
- **Secondary Workflow** — Mermaid diagram + description
  Each must include:
- Business Value
- Success Metrics

---

### 8. Integration Guide

**Audience:** Project Teams

- Development Setup (bash commands)
- Code Examples (JavaScript/Node.js + Python)
- Testing Strategy (unit & integration test examples)

---

### 9. Error Handling

**Audience:** Technical + Project Teams

- Standard Error Response (JSON example)
- Error Codes Reference (table)
- Error Handling Best Practices (code example)

---

### 10. Implementation Checklist

**Audience:** Project Teams

- Pre-Development (5–6 checkboxes)
- Development Phase (6–7 checkboxes)
- Testing Phase (6–7 checkboxes)
- Production Readiness (6–7 checkboxes)

---

### 11. Monitoring & Observability

**Audience:** Technical + Project Teams

- Key Metrics (5–6 metrics with targets)
- Logging Requirements (JSON example)
- Alerting Configuration (YAML example)

---

### 12. API Versioning & Evolution

**Audience:** All

- Current Version description
- Planned Enhancements (v1.1)
- Breaking Changes (v2.0 – Future)

---

### 13. Additional Resources

**Audience:** All

- For Stakeholders (3–4 links)
- For Technical Teams (4–5 links)
- For Project Teams (4–5 links)

---

### 14. Footer

---

CRITICAL: All output in one md document
