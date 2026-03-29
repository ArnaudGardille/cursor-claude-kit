# Skill: Infra Review

## When to use
Use when you need a **Terraform-first infrastructure review** for **AWS and/or Azure**: correctness, simplicity, operability, and safe patterns—not a generic application code review.

## Documentation protocol (do this before deep recommendations)

1. **Inventory Terraform from the repo:** `required_providers`, provider version constraints, backend configuration, module `source` / versions, and which roots (directories) exist.
2. **Ground provider and language behavior in current docs** — do not rely only on model cutoff knowledge:
   - Prefer **Context7 MCP**: `resolve-library-id` → `query-docs` for **Terraform CLI/language** and each **HashiCorp provider actually used** (commonly `hashicorp/aws`, `hashicorp/azurerm`, plus any others in `required_providers`).
   - If Context7 is unavailable, use **https://registry.terraform.io** provider documentation matching the versions/constraints in the repo.
3. When you cite behavior that depends on provider or Terraform version, tie it to **what the repo pins** or state uncertainty if unpinned.

## Context
The repository may contain Terraform, CI/CD that applies it, scripts, and runtime config for cloud services. It may include agent/LLM observability (e.g. Langfuse) or cloud AI services — **only review those if the codebase actually uses them**.

## Goal
Identify the highest-leverage improvements so infrastructure is **simpler, safer, less overengineered, easier to operate**, and **easier to change** without breaking production.

## Core review question
Are we using **Terraform and the relevant cloud(s)** in a clean, recommended, low-complexity way, or have we introduced unnecessary architecture, fragile IaC, weak observability, or unsafe operational patterns?

**Scope rule:** Deep-dive **AWS-specific** bullets only when `provider "aws"` or AWS modules/resources appear. Deep-dive **Azure-specific** bullets only when `provider "azurerm"` (or related Azure providers) appears. Skip sections that do not apply.

## Review for

### 1. Architecture simplicity
- Simpler than it needs to be?
- Too many services, layers, queues, functions, gateways, or glue?
- Managed platform capabilities replacing custom orchestration?
- Technically correct but operationally overcomplicated?

### 2. Terraform quality (when Terraform is present)
- Modular, readable, version-pinned (`required_providers`, `required_version`), easy to reason about?
- **State:** remote backend, locking, encryption, access control (e.g. S3+Dynamo vs Azure Storage+locking — match the repo).
- Module boundaries: right-sized or sprawl / over-abstraction?
- Variables, outputs, providers, naming, environment separation (workspaces vs roots vs state) clear?
- Duplication, hidden coupling, brittle cross-module dependencies?
- **`lifecycle`** / `prevent_destroy` where appropriate; **sensitive** values handled; secrets not in repo or plain state?
- Align with repo automation: `terraform validate`, `fmt`, **tflint**, CI if present.

### 3. Identity and access
- Least privilege for runtime identities, deploy principals, humans.
- **AWS:** IAM roles/policies tight; execution roles appropriate.
- **Azure:** RBAC scoped; managed identities; Key Vault RBAC or access policies least-privilege.

### 4. Networking and exposure
- Minimal public exposure; private connectivity where appropriate.
- Security groups / NSGs; TLS and certificates sane.

### 5. Compute, APIs, integration (if present)
- **AWS:** Lambda sizing, timeouts, concurrency, idempotency; API Gateway vs Function URLs justified; webhooks (signatures, DLQs, retries).
- **Azure:** Functions / App Service scaling and identity; API Management vs direct endpoints justified; Event Grid / Service Bus / Queues with dead-lettering.

**Mapping (review dimensions)**

| Concern | AWS (examples) | Azure (examples) |
|--------|----------------|------------------|
| Identity | IAM | RBAC, managed identities, Key Vault |
| HTTP ingress | API Gateway, ALB | API Management, App Gateway, Front Door |
| Short-lived compute | Lambda | Functions, Container Apps |
| Messaging | SQS, SNS, EventBridge | Service Bus, Event Grid, Storage Queues |
| Storage / secrets | S3, Secrets Manager | Storage accounts, Key Vault |

### 6. Reliability and operability
- Retries, backoff, idempotency, dead-letter handling for async paths?
- Reversible deployments; health checks, alerts, runbooks; SPOFs; incident troubleshooting (correlation IDs, structured logs).

### 7. Observability
- Metrics, logs, traces explain failures; dashboards and alerts; tags; no secret/PII over-logging.

### 8. Cost and performance
- Waste, data transfer, logging volume; complexity cost vs value.

### 9. Maintainability
- Future engineers understand layout and apply path; boundaries between app, IaC, deploy, observability clear.

### 10. Agents / LLM workloads (optional — only if repo uses them)
- Traces, correlation IDs, versioning linked to deployments; cloud AI services with least privilege and sensible limits.

### Explicit extras
- Redundant layers; Terraform over-abstraction; drift; weak pinning; unsafe state; secrets mishandling; missing webhook idempotency; mis-sized serverless; weak gateways; weak tracing/alarms.

## Output
- Start with **What’s good**
- Then **What should improve** — for each issue: severity, **category** (Architecture simplicity, Terraform, AWS, Azure, Identity, Networking, Compute/APIs/messaging, Reliability, Observability, Cost, Maintainability, LLM/agent observability if applicable), why it matters, **evidence from the repo**, likely failure mode, recommended fix, expected impact
- End with: **Top 5** simplifications, **quick wins** (under one hour), **structural fixes**, **suggested execution order**

## Guiding principles
Prefer **native managed patterns** for the cloud(s) in use. Prefer **fewer services** and **straightforward Terraform**. Prefer **observability that explains failures**. **Ground recommendations in the repo** and **current docs** for pinned versions (see Documentation protocol).
