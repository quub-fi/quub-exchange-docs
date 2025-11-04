---
layout: docs
permalink: /capabilities/documents/api-documentation/
title: documents API Documentation
service: documents
---

{% include api-nav-banner.html %}

# Documents API Documentation

_Based on OpenAPI specification: documents.yaml_

## Executive Summary

**Audience:** Stakeholders

The Documents API provides comprehensive document management, electronic signature workflows, and publication capabilities for Quub Exchange. This service enables secure multi-tenant document storage, audit logging, and compliance with electronic signature standards including eIDAS, UAE Pass, and DocuSign integration.

**Key Business Value:**

- **Regulatory Compliance**: Automated document workflows ensuring compliance with financial regulations
- **Operational Efficiency**: Streamlined document management reducing manual processes by 70%
- **Risk Mitigation**: Comprehensive audit trails and signature verification preventing disputes
- **Multi-Channel Distribution**: Secure publication system for investor communications and disclosures

**Strategic Importance:**

- Critical infrastructure for regulatory reporting and investor communications
- Foundation for digital transformation of document-intensive financial processes
- Enables scalable document management across multiple jurisdictions and languages

## Service Overview

**Audience:** All

**Business Purpose:**

- Provide secure, compliant document storage and management for financial institutions
- Enable electronic signature workflows for legal documents and contracts
- Support publication and distribution of regulatory filings and investor communications
- Ensure audit compliance and document integrity across the platform

**Technical Architecture:**

- Multi-tenant document storage with organization-level isolation
- Integration with e-signature providers (DocuSign, UAE Pass, eIDAS)
- RESTful API with comprehensive audit logging and versioning
- Support for multiple document formats (PDF, DOCX, XLSX, images)
- Secure file storage with encryption and access controls

## API Specifications

**Audience:** Technical

**Base Configuration:**

```yaml
openapi: 3.1.0
info:
  title: Quub Exchange - Document Management Service
  version: 2.0.0
servers:
  - url: https://api.quub.exchange/v2
  - url: https://api.sandbox.quub.exchange/v2
```

**Authentication & Authorization:**

- OAuth 2.0 with scopes: `read:documents`, `write:documents`
- API Key authentication for service-to-service calls
- Multi-tenant isolation with organization-level access controls
- Role-based permissions for document operations

## Core Endpoints

**Audience:** Technical + Project Teams

### Document Management

**GET /orgs/{orgId}/documents**
_List documents with filtering and pagination_

**Business Use Case:** Retrieve organization documents with status filtering for document management dashboards.

**Request Example:**

```bash
GET /orgs/123e4567-e89b-12d3-a456-426614174000/documents?status=PUBLISHED&limit=20
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Org-Id: 123e4567-e89b-12d3-a456-426614174000
```

**Response Example:**

```json
{
  "data": [
    {
      "id": "456e7890-e89b-12d3-a456-426614174001",
      "orgId": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Q3 Financial Report.pdf",
      "type": "PDF",
      "status": "PUBLISHED",
      "tags": ["financial", "quarterly"],
      "storageUrl": "https://storage.quub.exchange/...",
      "createdAt": "2025-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "cursor": "eyJwYWdlIjoyfQ==",
    "hasMore": true
  }
}
```

**Implementation Notes:**

- Use cursor-based pagination for large document sets
- Filter by status to show active vs archived documents
- Include tags for document categorization and search

**POST /orgs/{orgId}/documents**
_Upload new document with metadata_

**Business Use Case:** Upload financial documents, contracts, or regulatory filings with proper categorization.

**Request Example:**

```bash
POST /orgs/123e4567-e89b-12d3-a456-426614174000/documents
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="contract.pdf"
Content-Type: application/pdf

[file content]

--boundary
Content-Disposition: form-data; name="name"

Investment Agreement Q4 2025
--boundary
Content-Disposition: form-data; name="type"

PDF
--boundary--
```

**Response Example:**

```json
{
  "data": {
    "id": "789e0123-e89b-12d3-a456-426614174002",
    "orgId": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Investment Agreement Q4 2025",
    "type": "PDF",
    "status": "DRAFT",
    "storageUrl": "https://storage.quub.exchange/documents/789e0123...",
    "createdAt": "2025-01-20T14:25:00Z"
  }
}
```

**Implementation Notes:**

- Support file size limits (max 50MB per document)
- Validate file types and scan for malware
- Generate secure storage URLs with time-limited access

### Electronic Signatures

**POST /orgs/{orgId}/documents/{documentId}/signatures**
_Request electronic signatures for a document_

**Business Use Case:** Initiate signature workflows for contracts, agreements, or regulatory documents requiring multiple approvals.

**Request Example:**

```json
POST /orgs/123e4567-e89b-12d3-a456-426614174000/documents/789e0123-e89b-12d3-a456-426614174002/signatures
{
  "signers": [
    {
      "name": "John Smith",
      "email": "john.smith@investor.com",
      "role": "SIGNER"
    },
    {
      "name": "Legal Review",
      "email": "legal@quub.com",
      "role": "REVIEWER"
    }
  ],
  "method": "DOCUSIGN",
  "dueDate": "2025-02-01T23:59:59Z"
}
```

**Response Example:**

```json
{
  "data": {
    "id": "321e6547-e89b-12d3-a456-426614174003",
    "documentId": "789e0123-e89b-12d3-a456-426614174002",
    "method": "DOCUSIGN",
    "status": "PENDING",
    "signers": [
      {
        "name": "John Smith",
        "email": "john.smith@investor.com",
        "role": "SIGNER",
        "status": "PENDING"
      }
    ],
    "requestedAt": "2025-01-20T14:30:00Z"
  }
}
```

**Implementation Notes:**

- Support multiple e-signature providers
- Track signer status and completion timelines
- Send automated notifications for signature requests

### Publications

**GET /orgs/{orgId}/publications**
_List published documents available to stakeholders_

**Business Use Case:** Retrieve published documents for investor portals, regulatory filings, or public disclosures.

**Request Example:**

```bash
GET /orgs/123e4567-e89b-12d3-a456-426614174000/publications?limit=10
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response Example:**

```json
{
  "data": [
    {
      "id": "654e9870-e89b-12d3-a456-426614174004",
      "orgId": "123e4567-e89b-12d3-a456-426614174000",
      "documentId": "789e0123-e89b-12d3-a456-426614174002",
      "title": "Q4 2025 Investment Update",
      "category": "REPORT",
      "publishedAt": "2025-01-25T09:00:00Z",
      "audience": "INVESTORS",
      "documentUrl": "https://publications.quub.exchange/654e9870..."
    }
  ],
  "pagination": {
    "hasMore": false
  }
}
```

**Implementation Notes:**

- Control audience visibility (public, investors, internal)
- Maintain publication history and versioning
- Generate secure, trackable download URLs

## Security Implementation

**Audience:** Technical + Project Teams

**Multi-tenant Isolation:**

```yaml
# Organization-level data isolation
security:
  - oauth2:
      - read:documents
  - apiKey: []
parameters:
  - name: orgId
    in: path
    required: true
    schema:
      type: string
      format: uuid
```

**Data Protection Measures:**

- AES-256 encryption for stored documents
- TLS 1.3 for data transmission
- Secure file storage with access logging
- GDPR and SOX compliance for financial documents

**Access Controls:**

```json
{
  "roles": {
    "admin": ["read:documents", "write:documents", "delete:documents"],
    "manager": ["read:documents", "write:documents"],
    "viewer": ["read:documents"]
  },
  "permissions": {
    "document.upload": "write:documents",
    "document.publish": "admin",
    "signature.request": "write:documents"
  }
}
```

## Business Workflows

**Audience:** Stakeholders + Project Teams

### Primary Workflow — Document Lifecycle Management

```mermaid
graph TD
    A[Document Upload] --> B[Draft Status]
    B --> C[Review Process]
    C --> D{Approval?}
    D -->|Yes| E[Publish Document]
    D -->|No| F[Revision Required]
    F --> C
    E --> G[Signature Request]
    G --> H[Electronic Signing]
    H --> I[Final Publication]
    I --> J[Distribution]
```

**Business Value:** Streamlines document approval workflows, reducing processing time from weeks to days while maintaining compliance and audit trails.

**Success Metrics:**

- Document processing time: < 48 hours
- Signature completion rate: > 95%
- Audit compliance: 100%

### Secondary Workflow — Regulatory Reporting

```mermaid
graph TD
    A[Regulatory Requirement] --> B[Document Preparation]
    B --> C[Internal Review]
    C --> D[Legal Approval]
    D --> E[Electronic Signatures]
    E --> F[Publication]
    F --> G[Regulatory Submission]
    G --> H[Public Disclosure]
```

**Business Value:** Ensures timely regulatory compliance and transparent reporting to stakeholders.

**Success Metrics:**

- Regulatory filing accuracy: 100%
- On-time submission rate: > 98%
- Stakeholder satisfaction: > 4.5/5

## Integration Guide

**Audience:** Project Teams

**Development Setup:**

```bash
# Install dependencies
npm install axios form-data

# Environment configuration
export QUUB_API_KEY="your-api-key"
export QUUB_BASE_URL="https://api.sandbox.quub.exchange/v2"
```

**JavaScript/Node.js Example:**

```javascript
const axios = require("axios");
const FormData = require("form-data");
const fs = require("fs");

class QuubDocumentsAPI {
  constructor(apiKey, baseUrl = "https://api.sandbox.quub.exchange/v2") {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
    });
  }

  async uploadDocument(orgId, filePath, metadata) {
    const form = new FormData();
    form.append("file", fs.createReadStream(filePath));
    form.append("name", metadata.name);
    form.append("type", metadata.type);

    const response = await this.client.post(`/orgs/${orgId}/documents`, form, {
      headers: {
        ...form.getHeaders(),
        "X-Org-Id": orgId,
      },
    });

    return response.data;
  }

  async requestSignature(orgId, documentId, signers) {
    const response = await this.client.post(
      `/orgs/${orgId}/documents/${documentId}/signatures`,
      { signers, method: "DOCUSIGN" },
      { headers: { "X-Org-Id": orgId } }
    );

    return response.data;
  }

  async listDocuments(orgId, filters = {}) {
    const params = new URLSearchParams(filters);
    const response = await this.client.get(
      `/orgs/${orgId}/documents?${params}`,
      {
        headers: { "X-Org-Id": orgId },
      }
    );

    return response.data;
  }
}

// Usage example
const api = new QuubDocumentsAPI(process.env.QUUB_API_KEY);

async function processInvestmentDocument() {
  try {
    // Upload document
    const upload = await api.uploadDocument(
      "org-123",
      "./investment-agreement.pdf",
      {
        name: "Q4 Investment Agreement",
        type: "PDF",
      }
    );

    console.log("Document uploaded:", upload.data.id);

    // Request signatures
    const signature = await api.requestSignature("org-123", upload.data.id, [
      { name: "John Investor", email: "john@investor.com", role: "SIGNER" },
    ]);

    console.log("Signature requested:", signature.data.id);
  } catch (error) {
    console.error("API Error:", error.response?.data || error.message);
  }
}
```

**Python Example:**

```python
import requests
import os
from typing import List, Dict, Any

class QuubDocumentsClient:
    def __init__(self, api_key: str, base_url: str = "https://api.sandbox.quub.exchange/v2"):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        })

    def upload_document(self, org_id: str, file_path: str, name: str, doc_type: str) -> Dict[str, Any]:
        url = f"{self.base_url}/orgs/{org_id}/documents"

        with open(file_path, 'rb') as file:
            files = {'file': (os.path.basename(file_path), file, 'application/pdf')}
            data = {'name': name, 'type': doc_type}

            response = self.session.post(url, files=files, data=data,
                                      headers={'X-Org-Id': org_id})
            response.raise_for_status()
            return response.json()

    def request_signature(self, org_id: str, document_id: str, signers: List[Dict]) -> Dict[str, Any]:
        url = f"{self.base_url}/orgs/{org_id}/documents/{document_id}/signatures"

        payload = {
            'signers': signers,
            'method': 'DOCUSIGN'
        }

        response = self.session.post(url, json=payload, headers={'X-Org-Id': org_id})
        response.raise_for_status()
        return response.json()

    def list_documents(self, org_id: str, status: str = None) -> Dict[str, Any]:
        url = f"{self.base_url}/orgs/{org_id}/documents"
        params = {}
        if status:
            params['status'] = status

        response = self.session.get(url, params=params, headers={'X-Org-Id': org_id})
        response.raise_for_status()
        return response.json()

# Usage example
client = QuubDocumentsClient(os.getenv('QUUB_API_KEY'))

def process_compliance_document():
    try:
        # Upload compliance document
        upload = client.upload_document(
            org_id='123e4567-e89b-12d3-a456-426614174000',
            file_path='./kyc-document.pdf',
            name='KYC Compliance Report',
            doc_type='PDF'
        )

        print(f"Document uploaded: {upload['data']['id']}")

        # Request signatures from compliance officers
        signature = client.request_signature(
            org_id='123e4567-e89b-12d3-a456-426614174000',
            document_id=upload['data']['id'],
            signers=[
                {
                    'name': 'Compliance Officer',
                    'email': 'compliance@quub.com',
                    'role': 'SIGNER'
                }
            ]
        )

        print(f"Signature requested: {signature['data']['id']}")

    except requests.exceptions.RequestException as e:
        print(f"API Error: {e}")

if __name__ == "__main__":
    process_compliance_document()
```

**Testing Strategy:**

```bash
# Unit tests
npm test -- --grep "DocumentAPI"

# Integration tests
pytest tests/integration/test_documents.py -v

# Load testing
artillery run tests/load/documents.yml
```

## Error Handling

**Audience:** Technical + Project Teams

**Standard Error Response:**

```json
{
  "error": {
    "code": "DOCUMENT_UPLOAD_FAILED",
    "message": "File upload failed due to size limit exceeded",
    "details": {
      "maxSize": "50MB",
      "providedSize": "75MB"
    },
    "timestamp": "2025-01-20T14:30:00Z",
    "requestId": "req-12345"
  }
}
```

**Error Codes Reference:**

| Code                       | HTTP Status | Description                        | Resolution                                        |
| -------------------------- | ----------- | ---------------------------------- | ------------------------------------------------- |
| `DOCUMENT_NOT_FOUND`       | 404         | Document does not exist            | Verify document ID and organization access        |
| `INVALID_FILE_TYPE`        | 400         | Unsupported file format            | Check supported formats (PDF, DOCX, XLSX)         |
| `FILE_TOO_LARGE`           | 413         | File exceeds size limit            | Reduce file size or split into multiple documents |
| `SIGNATURE_EXPIRED`        | 410         | Signature request expired          | Create new signature request                      |
| `INSUFFICIENT_PERMISSIONS` | 403         | User lacks required permissions    | Check user roles and document access              |
| `STORAGE_QUOTA_EXCEEDED`   | 507         | Organization storage limit reached | Archive old documents or upgrade plan             |

**Error Handling Best Practices:**

```javascript
async function uploadWithRetry(orgId, filePath, maxRetries = 3) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      const result = await api.uploadDocument(orgId, filePath, metadata);
      return result;
    } catch (error) {
      attempt++;

      if (error.response?.status === 429) {
        // Rate limited - exponential backoff
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
        continue;
      }

      if (error.response?.status >= 500 && attempt < maxRetries) {
        // Server error - retry
        await new Promise((resolve) => setTimeout(resolve, 1000));
        continue;
      }

      // Non-retryable error or max retries reached
      throw error;
    }
  }
}
```

## Implementation Checklist

**Audience:** Project Teams

### Pre-Development

- [ ] Review document storage requirements and quotas
- [ ] Identify required e-signature providers (DocuSign, UAE Pass, etc.)
- [ ] Define document lifecycle workflows and approval processes
- [ ] Assess integration points with existing systems
- [ ] Plan audit logging and compliance reporting requirements
- [ ] Design document categorization and tagging strategy

### Development Phase

- [ ] Implement multi-tenant document storage with encryption
- [ ] Build file upload handling with validation and scanning
- [ ] Integrate e-signature providers and webhook handling
- [ ] Develop document versioning and audit trail functionality
- [ ] Implement publication system with access controls
- [ ] Create comprehensive API documentation and examples
- [ ] Build admin interface for document management

### Testing Phase

- [ ] Unit tests for all API endpoints (100% coverage)
- [ ] Integration tests for document upload and signature workflows
- [ ] Security testing for file handling and access controls
- [ ] Performance testing for large file uploads and concurrent access
- [ ] Cross-browser testing for document preview functionality
- [ ] Load testing for high-volume document processing
- [ ] Compliance testing for regulatory requirements

### Production Readiness

- [ ] Configure production storage and backup systems
- [ ] Set up monitoring and alerting for document operations
- [ ] Implement rate limiting and abuse prevention
- [ ] Configure SSL certificates and security headers
- [ ] Set up log aggregation and audit trail retention
- [ ] Train operations team on document management procedures
- [ ] Establish incident response procedures for document breaches

## Monitoring & Observability

**Audience:** Technical + Project Teams

**Key Metrics:**

- **Document Upload Success Rate**: Target > 99.5%
- **Average Upload Time**: Target < 30 seconds
- **Signature Completion Rate**: Target > 95%
- **Storage Utilization**: Monitor and alert at 80% capacity
- **API Response Time**: Target < 500ms for metadata operations
- **Error Rate**: Target < 0.1% for all operations

**Logging Requirements:**

```json
{
  "timestamp": "2025-01-20T14:30:00Z",
  "level": "INFO",
  "service": "documents",
  "operation": "document.upload",
  "orgId": "123e4567-e89b-12d3-a456-426614174000",
  "documentId": "789e0123-e89b-12d3-a456-426614174002",
  "userId": "456e7890-e89b-12d3-a456-426614174001",
  "fileSize": 2048576,
  "fileType": "PDF",
  "ipAddress": "192.168.1.100",
  "userAgent": "Quub-Web/1.0.0",
  "requestId": "req-12345"
}
```

**Alerting Configuration:**

```yaml
alerts:
  - name: High Error Rate
    condition: rate(error_total[5m]) > 0.05
    severity: critical
    description: "Document API error rate above 5%"

  - name: Storage Capacity Warning
    condition: storage_used_percent > 80
    severity: warning
    description: "Document storage utilization above 80%"

  - name: Slow Upload Performance
    condition: histogram_quantile(0.95, rate(upload_duration_seconds[5m])) > 60
    severity: warning
    description: "95th percentile upload time above 60 seconds"

  - name: Signature Request Failures
    condition: increase(signature_request_failures[1h]) > 5
    severity: error
    description: "More than 5 signature request failures in the last hour"
```

## API Versioning & Evolution

**Audience:** All

**Current Version:** v2.0.0

- Multi-tenant document management
- Electronic signature integration
- Publication and distribution system
- Comprehensive audit logging

**Planned Enhancements (v2.1):**

- Advanced document search and AI-powered categorization
- Bulk document operations and batch processing
- Enhanced collaboration features with comments and annotations
- Integration with additional e-signature providers
- Document watermarking and DRM capabilities

**Breaking Changes (v3.0 - Future):**

- Migration to GraphQL API for complex document queries
- Enhanced security with zero-knowledge encryption
- Blockchain-based document notarization
- AI-powered document analysis and insights

## Additional Resources

**Audience:** All

**For Stakeholders:**

- [Document Management Best Practices Guide](https://docs.quub.exchange/business/documents/best-practices)
- [Regulatory Compliance Overview](https://docs.quub.exchange/compliance/documents)
- [Electronic Signatures Legal Framework](https://docs.quub.exchange/legal/e-signatures)
- [Case Study: Digital Document Transformation](https://docs.quub.exchange/case-studies/digital-documents)

**For Technical Teams:**

- [OpenAPI Specification](https://api.quub.exchange/v2/docs/documents.yaml)
- [Postman Collection](https://api.quub.exchange/v2/postman/Documents.postman_collection.json)
- [SDK Documentation](https://docs.quub.exchange/developers/sdks/documents)
- [Webhook Documentation](https://docs.quub.exchange/developers/webhooks/documents)
- [Rate Limiting Guide](https://docs.quub.exchange/developers/rate-limits)

**For Project Teams:**

- [Implementation Guide](https://docs.quub.exchange/projects/documents-implementation)
- [Security Checklist](https://docs.quub.exchange/security/documents-checklist)
- [Migration Guide from Legacy Systems](https://docs.quub.exchange/migrations/documents)
- [Troubleshooting Common Issues](https://docs.quub.exchange/support/documents-troubleshooting)
- [Performance Optimization Tips](https://docs.quub.exchange/performance/documents)
