# HIPAA Technical Safeguards — Control Mapping

## Overview
This document maps each HIPAA Technical Safeguard requirement
to the specific AWS service or code implementation in this project.

## 164.312(a)(1) — Access Control

| Control | Implementation | Status |
|---|---|---|
| Unique user identification | providerId required on all PHI endpoints | ✅ |
| Emergency access | Break-glass IAM role documented | ✅ |
| Automatic logoff | JWT token expiry (future) | ⏳ |
| Encryption | KMS AES-256 on all PHI data | ✅ |

## 164.312(b) — Audit Controls

| Control | Implementation | Status |
|---|---|---|
| Hardware activity | CloudTrail logs all API calls | ✅ |
| Software activity | Application audit log on every PHI access | ✅ |
| Procedure activity | GET /api/v1/audit endpoint | ✅ |
| Immutable logs | S3 audit bucket with KMS encryption | ✅ |

## 164.312(c)(1) — Integrity

| Control | Implementation | Status |
|---|---|---|
| PHI not altered | S3 versioning enabled on PHI bucket | ✅ |
| Transmission integrity | TLS enforced via security groups | ✅ |

## 164.312(d) — Person Authentication

| Control | Implementation | Status |
|---|---|---|
| Verify identity | providerId on all endpoints | ✅ |
| MFA (future) | Cognito integration planned | ⏳ |

## 164.312(e)(1) — Transmission Security

| Control | Implementation | Status |
|---|---|---|
| Encryption in transit | TLS 1.2+ enforced | ✅ |
| Network controls | VPC private subnets | ✅ |
| WAF protection | Blocks OWASP Top 10 | ✅ |
