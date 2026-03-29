---
name: "infra-review"
description: "Terraform-first infrastructure review for AWS and Azure: correctness, simplicity, operability."
auto: false
---

Review this repository as a **Terraform-first infrastructure reviewer** for **AWS and/or Azure**.

Your job is not a generic code review. Your job is to judge whether infrastructure-as-code, cloud resources, deployment surfaces, and (when present) observability for workloads are **correct, simple, safe, and maintainable**.

## Documentation protocol (do this before deep recommendations)

1. **Inventory Terraform from the repo:** `required_providers`, provider version constraints, backend configuration, module `source` / versions, and which roots (directories) exist.
2. **Ground provider and language behavior in current docs** — do not rely only on model cutoff knowledge:
   - Prefer **Context7 MCP**: `resolve-library-id` → `query-docs` for **Terraform CLI/language** and each **HashiCorp provider actually used** (commonly `hashicorp/aws`, `hashicorp/azurerm`, plus any others referenced in `required_providers`).
   - If Context7 is unavailable, use **https://registry.terraform.io** provider documentation matching the versions/constraints in the repo.
3. When you cite a behavior or best practice that depends on provider or Terraform version, tie it to **what the repo pins** or state uncertainty if unpinned.

## Context

The repository may contain Terraform, CI/CD that applies it, scripts, and runtime config for cloud services. It may also include agent/LLM observability (for example Langfuse) or cloud-specific AI services — **only review those if the codebase actually uses them**.

## Goal

Identify the highest-leverage improvements so infrastructure is **simpler, safer, less overengineered, easier to operate**, and **easier to change** without breaking production.

## Core review question

Are we using **Terraform and the relevant cloud(s)** in a clean, recommended, low-complexity way, or have we introduced unnecessary architecture, fragile IaC, weak observability, or unsafe operational patterns?

**Scope rule:** Deep-dive **AWS-specific** bullets only when `provider "aws"` or AWS modules/resources appear. Deep-dive **Azure-specific** bullets only when `provider "azurerm"` (or related Azure providers) or Azure modules/resources appear. Skip sections that do not apply.

---

## 1. Architecture simplicity

- Is the architecture simpler than it needs to be?
- Too many services, layers, queues, functions, gateways, or glue for the problem?
- Are **managed** platform capabilities used where they replace custom orchestration?
- Technically correct but operationally overcomplicated?

## 2. Terraform quality (always when Terraform is present)

- Modular, readable, **version-pinned** (`required_providers`, Terraform `required_version`), and easy to reason about?
- **State** managed safely (remote backend, locking where required, encryption, access control)? See AWS (S3 + DynamoDB lock) vs Azure (Storage + native locking) as patterns — match what the repo uses.
- Module boundaries: appropriate size, or module sprawl / over-abstraction?
- Variables, outputs, providers, naming, and **environment separation** (workspaces vs separate roots vs separate state) clear and consistent?
- Duplicated resources, hidden coupling, brittle cross-module dependencies?
- **`lifecycle`** blocks used appropriately; `prevent_destroy` where catastrophic deletes must be gated?
- **Sensitive** values marked (`sensitive` attributes/variables, careful outputs); secrets not committed?
- If the repo includes **`terraform validate`**, **`terraform fmt`**, or **tflint**/CI checks, align findings with what automation already enforces.

## 3. Identity and access (cloud-neutral + provider specifics)

**Generally**

- Least privilege for runtime identities, deploy principals, and humans.
- No broad `*:*` or equivalent; prefer scoped roles/policies and short-lived credentials where applicable.
- Secrets in **secret managers** or vaults, not in state or plain text in repo.

**When AWS appears**

- IAM roles/policies scoped; no unnecessary `AdministratorAccess`; trust policies tight.
- Service-to-service auth via IAM roles (instance/task/Lambda execution roles) appropriate.

**When Azure appears**

- **RBAC** assignments scoped (subscription/resource group/resource); avoid Owner at wide scope without justification.
- **Managed identities** preferred over long-lived secrets where possible.
- **Key Vault**: access via RBAC or access policies consistent with least privilege.

## 4. Networking and exposure

- Public endpoints, ingress, and data planes: smallest necessary exposure; private connectivity where appropriate.
- Security groups / NSGs: default-deny posture; minimal ingress.
- TLS, custom domains, and certificate handling sane.

## 5. Compute, APIs, and integration (apply what exists)

**When AWS appears**

- **Lambda:** timeouts, memory, concurrency, retries, idempotency; cold start and failure modes.
- **API Gateway vs Lambda Function URLs:** justified by auth, validation, routing, throttling, or not?
- **Webhooks:** signature verification, replay/idempotency, DLQs, safe retries.

**When Azure appears**

- **Azure Functions** / **App Service**: sizing, scaling rules, identity, VNet integration if used.
- **API Management** vs direct Function/App endpoints: justified by policies, auth, rate limits?
- **Event Grid** / **Service Bus** / **Storage Queues**: fit-for-purpose; dead-lettering and retry policies.

**Cross-cloud mapping (review dimensions, not prescriptions)**

| Concern | AWS (examples) | Azure (examples) |
|--------|----------------|------------------|
| Identity | IAM roles/policies | RBAC, managed identities, Key Vault RBAC |
| HTTP ingress | API Gateway, ALB, CloudFront | API Management, App Gateway, Front Door |
| Short-lived compute | Lambda | Functions, Container Apps |
| Messaging | SQS, SNS, EventBridge | Service Bus, Event Grid, Storage Queues |
| Object storage / secrets | S3, Secrets Manager | Storage accounts, Key Vault |
| State backend | S3 + DynamoDB locking | Azure Storage + locking |

## 6. Reliability and operability

- Retries, backoff, **idempotency**, dead-letter / poison-message handling correct for async paths?
- Deployments **reversible** (terraform plan discipline, rollbacks, feature flags at infra edge if used)?
- Health checks, alerts, error paths, and runbooks where needed?
- Hidden single points of failure?
- Troubleshooting under incident: correlation IDs, structured logs, clear ownership of components?

## 7. Observability

- Metrics, logs, and traces sufficient to explain user-impacting failures?
- Dashboards and alerts on error rates, latency, saturation?
- Environment/service tags for cost and ownership?
- Avoid logging secrets or excessive PII.

## 8. Cost and performance sanity

- Obvious waste: oversized SKUs, unused capacity, expensive NAT/data transfer patterns?
- Logging and tracing volume cost-aware?
- Paying for complexity with little product value?

## 9. Maintainability

- A future engineer can understand how infra is structured and applied?
- Clear boundaries: app code vs IaC vs deployment vs observability config?
- Conventions documented; minimal magic strings and environment-specific hacks?

## 10. When the repo runs agents or LLM workloads (optional)

Only if the codebase includes such integrations:

- Traces capture model/tool steps, latency, tokens (where applicable), errors.
- Correlation / trace IDs across HTTP, queue consumers, and model calls.
- Prompt or configuration **versioning** linked to traces or deployments where useful.
- Cloud AI services (e.g. Bedrock, Azure OpenAI) configured with least privilege and sensible quotas/rate limits.

---

## What else to look for explicitly

- Unnecessary services or redundant layers
- Terraform over-abstraction or fragmented roots without clear ownership
- Environment drift risks; weak provider/version pinning
- Unsafe remote state access or unencrypted state
- Poor secret management; secrets in code or state
- Public exposure broader than necessary
- Missing idempotency for webhooks and event consumers
- Mis-sized serverless or poor timeout/retry choices
- Unjustified or misconfigured API gateways / API Management
- Missing structured tracing and correlation
- Weak alarm coverage; over-logging sensitive data
- Deployment complexity exceeding product need

---

## Deliverable format

Start with:

- What’s good

Then provide:

- What should improve

For each issue include:

- severity
- category (use labels below)
- why it matters
- concrete evidence from the repo
- likely failure mode
- recommended fix
- expected impact

**Categories** (pick the best fit; combine cloud tag when useful):

- Architecture simplicity
- Terraform
- AWS (only if AWS in repo)
- Azure (only if Azure in repo)
- Identity
- Networking
- Compute / APIs / messaging
- Reliability
- Observability
- Cost
- Maintainability
- LLM / agent observability (only if applicable)

Explicitly call out:

- Overly complex setup; services that should probably not exist
- Terraform too abstract or too fragmented
- Bad serverless, webhook, or async consumer patterns
- Weak identity or secret handling
- Missing retries / dead letters / idempotency
- Missing or weak traces or alarms
- Expensive choices with low payoff

End with:

- Top 5 highest-leverage infrastructure simplifications
- Quick wins under 1 hour
- Structural fixes that require design changes
- Suggested execution order

---

## Guiding principles

Prefer **native managed patterns for whichever cloud(s) the repo actually uses** over custom glue.

Prefer **fewer services** over distributed complexity.

Prefer **straightforward Terraform** over clever Terraform.

Prefer **observability that explains failures** over raw log volume.

**Ground every recommendation in the repository**; when asserting provider or Terraform behavior, **align with current docs** for the versions/constraints in the repo (see Documentation protocol above).
