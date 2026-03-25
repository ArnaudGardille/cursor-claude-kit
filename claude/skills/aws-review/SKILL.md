---
name: "aws-review"
description: "Infra correctness + simplicity + operability review."
auto: false
---

Review this repository as an AWS + AI platform infrastructure reviewer.

Your job is not to do a generic code review. Your job is to review whether the AWS infrastructure, Terraform, serverless setup, and AI-agent platform integrations are set up correctly, simply, safely, and in a maintainable way.

Context:
This repository may contain Terraform, deployment scripts, AWS service configurations, serverless functions, webhook endpoints, API Gateway configuration, IAM policies, secrets handling, observability setup, and AI-agent platform integrations such as Amazon Bedrock AgentCore and Langfuse.

Goal:
Identify the highest-leverage improvements to make the infrastructure simpler, safer, less overengineered, easier to operate, and easier to change without breaking production.

Core review question:
Are we using AWS services and related tooling in a clean, recommended, low-complexity way, or have we introduced unnecessary architecture, fragile Terraform, weak observability, or unsafe operational patterns?

Review for:

1. Architecture simplicity
- Is the architecture simpler than it needs to be?
- Are there too many services, layers, queues, functions, gateways, or glue components for the problem?
- Are we using managed AWS capabilities where they would replace custom code or orchestration?
- Are there places where the setup is technically correct but operationally overcomplicated?

2. AWS service usage
- Are AWS services used in the recommended way?
- Are there services being used for problems they are not well suited for?
- Are there places where a simpler AWS-native pattern would be better?
- Are there misconfigurations or anti-patterns in networking, IAM, storage, compute, messaging, or eventing?

3. Terraform quality
- Is the Terraform modular, readable, version-pinned, and easy to reason about?
- Is state managed safely and correctly?
- Are modules appropriately sized, or is there module sprawl / over-abstraction?
- Are variables, outputs, providers, naming, and environment separation clear?
- Are there duplicated resources, hidden coupling, or brittle cross-module dependencies?
- Are we overengineering the IaC instead of keeping it straightforward?

4. Lambda, webhook, and API setup
- Are Lambda functions configured with sensible timeouts, memory, retry behavior, concurrency, and idempotency expectations?
- Are webhook endpoints implemented in the simplest safe way?
- If using Lambda Function URLs, is that appropriate?
- If using API Gateway, is it justified by auth, validation, routing, throttling, or other requirements?
- Are request validation, authentication, signature verification, retries, DLQs, and failure modes handled correctly?
- Are event-driven flows easy to understand and debug?

5. Agent platform setup
- If using Amazon Bedrock AgentCore, is it used in the recommended way?
- Are we using AgentCore components only where they add value, or are we adding unnecessary platform complexity?
- Are runtime, gateway, memory, observability, and evaluations configured coherently?
- Is the agent deployment model simple and production-oriented?

6. Langfuse and observability
- Are traces properly set up?
- Do traces capture prompts, model responses, tool calls, latency, token usage, and relevant metadata?
- Are prompts versioned and linked to traces?
- Is there enough information to debug failures end-to-end?
- Are there missing dashboards, alerts, correlation IDs, or environment tags?
- Can we understand what happened in production without reading raw logs everywhere?

7. Security and access control
- Is IAM scoped with least privilege?
- Are secrets managed correctly?
- Are public endpoints, webhooks, and APIs protected appropriately?
- Are state files, logs, buckets, queues, and databases configured safely?
- Are there security-sensitive defaults that are too permissive?

8. Reliability and operability
- Are retries, backoff, idempotency, and dead-letter handling correct?
- Are deployments safe and reversible?
- Are health checks, alarms, error handling, and runbooks present where needed?
- Are there hidden single points of failure?
- Is the system easy to troubleshoot under incident conditions?

9. Cost and performance sanity
- Are there obvious wasteful resources, always-on services, or expensive architectural choices?
- Are Lambda, storage, logging, NAT, API, and data-transfer patterns cost-aware?
- Are there places where the system is paying a lot for complexity that brings little value?

10. Maintainability
- Will a future engineer understand how this infrastructure works?
- Are the boundaries between app code, infrastructure code, deployment code, and observability code clear?
- Are conventions documented and enforced?
- Are there magic strings, scattered config, or environment-specific hacks?

What else to look for explicitly:
- unnecessary AWS services or redundant layers
- Terraform over-abstraction
- environment drift risks
- weak provider/version pinning
- unsafe remote state handling
- poor secret management
- public exposure that is broader than necessary
- missing idempotency for webhooks and event consumers
- Lambda mis-sizing or poor timeout/retry choices
- misuse of API Gateway vs Lambda Function URLs
- missing structured tracing and correlation across app, infra, and LLM calls
- weak AgentCore integration patterns
- incomplete Langfuse instrumentation
- poor alarm coverage
- over-logging sensitive data
- deployment complexity that exceeds the product need

Deliverable format:

Start with:
- What’s good

Then provide:
- What should improve

For each issue include:
- severity
- category
- why it matters
- concrete evidence from the repo
- likely failure mode
- recommended fix
- expected impact

Use categories such as:
- Architecture simplicity
- AWS service usage
- Terraform
- Lambda / webhooks
- API Gateway
- IAM / security
- Secrets / state
- Reliability
- Observability
- AgentCore
- Langfuse
- Cost
- Maintainability

Explicitly call out:
- overly complex setup
- services that should probably not exist
- Terraform that is too abstract or too fragmented
- bad Lambda or webhook patterns
- API Gateway usage that is unjustified or misconfigured
- poor IAM or secret handling
- missing retries / DLQs / idempotency
- missing or weak traces
- incorrect or weak AgentCore setup
- incomplete Langfuse integration
- expensive architecture choices with low payoff

End with:
- Top 5 highest-leverage infrastructure simplifications
- Quick wins under 1 hour
- Structural fixes that require design changes
- Suggested execution order

Guiding principles:
Prefer simpler AWS-native patterns over custom glue.
Prefer fewer services over distributed complexity.
Prefer straightforward Terraform over clever Terraform.
Prefer managed capabilities over bespoke infrastructure.
Prefer observability that explains failures over log volume.
Ground every recommendation in the actual repository, not generic cloud advice.