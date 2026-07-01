# High Level Design: OASIS

> **Document hierarchy:** This is the top-level architectural document for OASIS.
> Lower-level documents (LLDs, PRDs) reference this document for system-wide constraints and principles.
>
> **Related documents:**
> - [PRD.md](PRD.md) — Product requirements and functional specification
> - [RESEARCH.md](RESEARCH.md) — Competitive landscape and market analysis

---

## 1. Project Vision

OASIS (Obviously Awesome Student Information System) is the "Linux of Student Information Systems" — a minimal, stable kernel that schools can extend through plugins without being locked into a proprietary ecosystem.

The incumbents (PowerSchool, Skyward) have demonstrated that centralized, closed SIS platforms create catastrophic outcomes: the largest breach of children's data in US history, GPA miscalculations affecting college applications, and platforms so hostile to use that teachers forfeited pay raises to escape them. OASIS exists to offer a trustworthy, auditable, extensible alternative.

The system is **open-source and self-hostable first**, designed so that migration to a managed SaaS offering is achievable without architectural rework.

---

## 2. Stakeholders & Users

| Role | Description | Primary Concern |
|---|---|---|
| School Administrator | Configures and manages the system | Data accuracy, security, compliance |
| Teacher | Enters grades and attendance | Reliability, speed, mobile access |
| Parent | Views student progress | Simplicity, transparency |
| Student | Views own records, requests data | Self-service, data portability |
| District IT | Deploys and maintains the system | Operability, upgrades, support |
| Plugin Developer | Extends OASIS with new functionality | Stable contracts, clear docs |
| OASIS Maintainer (catdevman) | Develops and supports the core | Sustainability, clean architecture |

---

## 3. System Boundaries

**OASIS is responsible for:**
- Lifecycle management of plugin processes (boot, routing, shutdown)
- Authentication and authorization at the gateway level
- Database schema ownership and migration management
- The shared plugin contract (interface, transport, handshake)
- Configuration loading and plugin discovery

**OASIS is NOT responsible for:**
- Business logic (grades, attendance, scheduling) — this belongs in plugins
- Frontend UI — this is a plugin concern
- External identity provider management (SAML IdP, OAuth server)
- Data that lives outside the OASIS database (district HR systems, LMS, etc.)

---

## 4. High-Level Architecture

```
                         ┌─────────────────────────────────────┐
                         │             OASIS Host              │
                         │                                     │
  HTTP Request ─────────►│  Auth Middleware (gateway)          │
                         │       │                             │
                         │       ▼                             │
                         │  Prefix Router                      │
                         │       │                             │
                         │       ▼                             │
                         │  Plugin RPC Client ─────────────────┼──► Plugin Process A
                         │                    ─────────────────┼──► Plugin Process B
                         │                    ─────────────────┼──► Plugin Process N
                         │                                     │
                         │  Migration Runner (startup)         │
                         └──────────────┬──────────────────────┘
                                        │
                                        ▼
                              ┌─────────────────┐
                              │   PostgreSQL    │
                              │   (shared)      │
                              └─────────────────┘
```

**Request flow:**
1. HTTP request arrives at the host on `:8080`
2. Auth middleware validates the token (API key or SAML session)
3. Prefix router matches the URL to the best-registered plugin prefix
4. Request is serialized and forwarded to the plugin process via RPC
5. Plugin deserializes, handles internally with its own `http.ServeMux`, and returns a response
6. Host writes the response back to the original caller

**Startup flow:**
1. Host reads `plugins.yaml`
2. Host opens the database and runs pending migrations from `migrations/`
3. Host spawns each plugin binary as a child process, injecting config via environment variables
4. Host registers each plugin's prefix and begins serving

**Shutdown flow:**
1. Host receives `SIGINT` or `SIGTERM`
2. Host kills all child plugin processes
3. Host exits

---

## 5. Core Design Principles

These principles govern every component in the system. LLD authors must not violate them without first updating this document.

### 5.1 The Host is a Dumb Router
The host contains no business logic. It routes requests, manages plugin lifecycles, and enforces authentication. All domain logic (grades, attendance, enrollment) lives in plugins.

### 5.2 Plugins are Isolated Processes
Each plugin runs as an independent OS process. A crashing plugin cannot bring down the host or other plugins. Plugins communicate with the host only through the shared RPC contract.

### 5.3 The Shared Contract is the Only Coupling Point
The `shared/` package is the API between host and plugins. It defines the `HTTPPlugin` interface, transport structs (`HTTPRequest`, `HTTPResponse`), and the handshake config. Plugins import `shared/`. The host imports `shared/`. Nothing else is shared.

### 5.4 Authentication is Enforced at the Gateway
No plugin is responsible for validating identity. Auth happens in the host before a request reaches any plugin. Plugins may enforce authorization (role-based access to their own routes) but must not re-implement authentication.

### 5.5 The Database Schema is Owned by the Host & Common Plugin
The host acts as the migration runner, but the core schema is conceptually owned by the required "Common" plugin. Migrations live in `migrations/` and are numbered/versioned sequentially. Plugins can only append schema in their specific domains, never altering the core.

### 5.6 Self-Hosted First, SaaS-Ready by Design
All configuration is file-based and environment-variable-driven. There are no hardcoded deployment assumptions. This ensures a self-hosted instance and a future SaaS deployment differ only in infrastructure, not application code.

---

## 6. Technology Choices & Rationale

| Technology | Choice | Why |
|---|---|---|
| Language | Go 1.23+ | Strong concurrency model, single-binary deploys, fits the plugin process model |
| Plugin system | `hashicorp/go-plugin` | Battle-tested RPC-based plugin framework; process isolation by default |
| Database | PostgreSQL | Ed-Fi ODS compatibility; production-grade concurrency; path to managed SaaS hosting |
| DB migration tool | File-based SQL in `migrations/` | Simple, auditable, no magic; host runs them at startup |
| Configuration | YAML (`plugins.yaml`) | Human-readable, easy to diff, sufficient for the current config surface |
| Plugin transport | `net/rpc` over local socket | Low latency for same-host communication; no network overhead |
| Auth (planned) | API keys (M2M) + SAML/SSO | API keys for machine-to-machine; SAML for district SSO integration with existing IdPs |
| Education standard | Ed-Fi ODS schema | Industry-standard data model for K-12; enables interoperability with other district tools |

---

## 7. Cross-Cutting Concerns

Every LLD must address how its component handles these concerns. The standard approaches are defined here.

### 7.1 Authentication & Authorization

**Authentication** (who are you?) is handled by the host gateway before any plugin sees a request. Two token types are supported:

- **API Keys** — static tokens for machine-to-machine access (e.g., data import scripts, external integrations). Validated by the host.
- **SAML/SSO** — federated identity for human users via the district's existing identity provider. The host validates the SAML assertion and attaches a user identity to the forwarded request.

Unauthenticated requests are rejected at the gateway with `401 Unauthorized`. Plugins receive only authenticated requests.

**Authorization** (what can you do?) is a plugin concern. Plugins may inspect the forwarded user identity to enforce role-based access to their own routes.

### 7.2 Database Access

All plugins access a shared PostgreSQL instance. The host injects the connection string via the `OASIS_DB_DSN` environment variable.

Plugin database rules:
- Plugins connect using the shared `shared.OpenDatabase()` helper which assigns a restricted PostgreSQL Role.
- **Read-Only Core:** Plugins only have `SELECT` access to the core tables owned by the "Common" plugin.
- **Event-Based Mutations:** To write to core tables, plugins must send an RPC event to the "Common" plugin, which acts as the gatekeeper.
- **Bounded Writes:** Plugins only have write privileges for tables within their declared `tables` prefix (defined in `plugins.yaml`).
- Plugins never alter schema directly — migrations are the host's responsibility.
- Connection pooling settings are standardized and applied by the shared helper.

### 7.3 Plugin Contract Stability

The `shared/` package is a public API. Breaking changes require a version bump and a migration path. Plugin authors must not be broken by host upgrades without notice.

### 7.4 Graceful Shutdown

On `SIGINT` or `SIGTERM`, the host kills all plugin processes before exiting. Plugins must not require manual cleanup — any state that needs to survive shutdown must be flushed to the database before the process is killed.

### 7.5 Observability

Structured logging is the baseline. Each component logs to stdout. The host prefixes log lines with the plugin name when routing requests. Future work: distributed tracing for cross-plugin request flows.

### 7.6 Plugin Discovery, Versioning & Conflict Prevention

Plugins register a URL prefix and their schema dependencies in `plugins.yaml`. The host uses longest-prefix matching for routing. 
Crucially, plugins must declare the version of the "Common" core tables they support, as well as versions of any other plugins they depend on. The Host validates this dependency graph at startup and refuses to boot if versions are incompatible. Duplicate prefixes are also caught at startup.

---

## 8. Deployment Model

### 8.1 Self-Hosted (Current)
Schools run OASIS on their own infrastructure. The host binary, plugin binaries, and a PostgreSQL instance are the only runtime requirements. Configuration is via `plugins.yaml`. No external services required.

### 8.2 SaaS (Future)
A managed deployment where OASIS is hosted by the maintainer. The application code is identical to self-hosted. The delta is infrastructure only: managed PostgreSQL, reverse proxy/TLS termination, and a tenant isolation layer (to be designed). The self-hosted first principle ensures no SaaS assumptions have leaked into application code.

---

## 9. Known Constraints & Non-Goals

| Constraint | Detail |
|---|---|
| Authentication is not yet implemented | All endpoints are currently unprotected. This is the highest-priority gap before any production use. |
| SQLite → PostgreSQL migration in progress | Current code still has SQLite paths. PostgreSQL is the target; SQLite will be removed. |
| No frontend exists | All interfaces are JSON APIs. A frontend plugin is on the roadmap. |
| No plugin registry | Plugins are discovered via `plugins.yaml` only. A community plugin registry is a future concern. |
| Commercial use requires permission | No license is currently published. Contact catdevman before any commercial use. |
| Single-node only | Multi-node/clustered deployments are not supported. PostgreSQL handles concurrent access; host scaling is not yet designed. |

---

## 10. Roadmap

These items are architectural in nature and will each require an LLD before implementation.

| Item | Priority | Notes |
|---|---|---|
| Auth gateway (API keys + SAML) | Critical | Required before any production use |
| SQLite → PostgreSQL migration | Critical | Required for Ed-Fi ODS and SaaS readiness |
| Ed-Fi ODS schema adoption | High | Replaces current custom schema; enables district interoperability |
| Duplicate route conflict detection | High | Catch at startup, not runtime |
| Plugin load order / dependency resolution | Medium | Needed as plugin count grows |
| Frontend plugin | Medium | Unified UI that aggregates plugin UI fragments |
| Community plugin support | Medium | Plugin signing, registry, versioned contracts |
| Containerization | Medium | Dockerfile for reproducible self-hosted deploys |
| WCAG 2.1 AA accessibility | High (compliance) | ADA Title II deadline was April 24, 2026 — applies to all user-facing plugins |
| Multi-tenancy / SaaS layer | Low (future) | Tenant isolation design; do not bake assumptions into current code |
