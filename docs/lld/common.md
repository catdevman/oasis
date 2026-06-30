# LLD: Common Plugin

> **Document hierarchy:**
> - Parent: [HLD.md](../../HLD.md)
> - Domain LLDs: See [Domain Index](#domain-index) below
>
> This document defines the scope, structure, and conventions for the OASIS common plugin.
> All 19 core Ed-Fi ODS domains are implemented within this plugin.
> Each domain has its own LLD (linked below) that references this document for shared conventions.

---

## 1. Responsibility

The common plugin owns all core Ed-Fi ODS domains required to operate OASIS as a functional SIS. It is the primary plugin in any OASIS deployment. It is a single OS process managed by the host, communicating via the shared RPC contract defined in `shared/`.

The common plugin does **not** own:
- Authentication or authorization enforcement (host responsibility)
- Database schema migrations (host responsibility)
- Finance domain (separate third-party plugin)
- Any frontend/UI concerns

---

## 2. Domain Index

| # | Domain | LLD | Status |
|---|---|---|---|
| 1 | Education Organization | [01_education_org.md](common/01_education_org.md) | Planned |
| 2 | Student | [02_student.md](common/02_student.md) | Planned |
| 3 | Staff | [03_staff.md](common/03_staff.md) | Planned |
| 4 | Calendar | [04_calendar.md](common/04_calendar.md) | Planned |
| 5 | Course Catalog | [05_course_catalog.md](common/05_course_catalog.md) | Planned |
| 6 | Section | [06_section.md](common/06_section.md) | Planned |
| 7 | Student Section Association | [07_student_section_association.md](common/07_student_section_association.md) | Planned |
| 8 | Attendance | [08_attendance.md](common/08_attendance.md) | Planned |
| 9 | Grades | [09_grades.md](common/09_grades.md) | Planned |
| 10 | Program | [10_program.md](common/10_program.md) | Planned |
| 11 | Discipline | [11_discipline.md](common/11_discipline.md) | Planned |
| 12 | Bell Schedule | [12_bell_schedule.md](common/12_bell_schedule.md) | Planned |
| 13 | Credential | [13_credential.md](common/13_credential.md) | Planned |
| 14 | Graduation Plan | [14_graduation_plan.md](common/14_graduation_plan.md) | Planned |
| 15 | Student Academic Record | [15_student_academic_record.md](common/15_student_academic_record.md) | Planned |
| 16 | Cohort | [16_cohort.md](common/16_cohort.md) | Planned |
| 17 | Intervention | [17_intervention.md](common/17_intervention.md) | Planned |
| 18 | Post-Secondary Events | [18_post_secondary_events.md](common/18_post_secondary_events.md) | Planned |
| 19 | Assessment | [19_assessment.md](common/19_assessment.md) | Planned |

---

## 3. Package Structure

The common plugin is organized as a multi-package Go module. Each Ed-Fi domain is an internal sub-package with its own handler and repository. The top-level `plugin.go` wires all domains into a single `http.ServeMux`.

```
plugin/common/
  main.go                        Entry point — calls plugin.Serve()
  plugin.go                      CommonPlugin struct, ServeHTTP adapter, route registration
  internal/
    educationorg/
      handler.go                 HTTP handlers for education org routes
      repository.go              Database queries for education org
    student/
      handler.go
      repository.go
    staff/
      handler.go
      repository.go
    calendar/
      handler.go
      repository.go
    coursecatalog/
      handler.go
      repository.go
    section/
      handler.go
      repository.go
    studentsection/
      handler.go
      repository.go
    attendance/
      handler.go
      repository.go
    grades/
      handler.go
      repository.go
    program/
      handler.go
      repository.go
    discipline/
      handler.go
      repository.go
    bellschedule/
      handler.go
      repository.go
    credential/
      handler.go
      repository.go
    graduation/
      handler.go
      repository.go
    academicrecord/
      handler.go
      repository.go
    cohort/
      handler.go
      repository.go
    intervention/
      handler.go
      repository.go
    postsecondary/
      handler.go
      repository.go
    assessment/
      handler.go
      repository.go
```

### 3.1 Handler Convention

Each `handler.go` exposes a single type that holds a reference to its repository and registers its own routes onto the shared mux:

```go
type Handler struct {
    repo *Repository
}

func (h *Handler) Register(mux *http.ServeMux) {
    mux.HandleFunc("GET /ed-fi/students", h.list)
    mux.HandleFunc("GET /ed-fi/students/{id}", h.get)
    mux.HandleFunc("POST /ed-fi/students", h.create)
    mux.HandleFunc("PUT /ed-fi/students/{id}", h.update)
    mux.HandleFunc("DELETE /ed-fi/students/{id}", h.delete)
}
```

### 3.2 Repository Convention

Each `repository.go` owns all SQL for its domain. It receives a `*sql.DB` at construction. It does not manage transactions that span other domains — cross-domain writes are the caller's responsibility.

```go
type Repository struct {
    db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
    return &Repository{db: db}
}
```

### 3.3 Plugin Wiring (plugin.go)

`plugin.go` constructs all repositories and handlers, then calls `Register` on each:

```go
func New(db *sql.DB) *CommonPlugin {
    mux := http.NewServeMux()

    educationorg.NewHandler(educationorg.NewRepository(db)).Register(mux)
    student.NewHandler(student.NewRepository(db)).Register(mux)
    // ... all 19 domains

    return &CommonPlugin{mux: mux}
}
```

---

## 4. Route Convention

All routes follow the Ed-Fi ODS REST API pattern, relative to the plugin's registered prefix (`api/common`).

| Pattern | Description |
|---|---|
| `GET /ed-fi/{resource}` | List resources (paginated) |
| `GET /ed-fi/{resource}/{id}` | Get single resource by ID |
| `POST /ed-fi/{resource}` | Create resource |
| `PUT /ed-fi/{resource}/{id}` | Full update |
| `DELETE /ed-fi/{resource}/{id}` | Delete resource |

Full URL example: `GET /api/common/ed-fi/students`

**Rules:**
- Resource names are plural and kebab-case (e.g., `education-organizations`, `student-section-associations`)
- IDs are UUIDs
- All list endpoints support `limit` and `offset` query parameters
- All responses are JSON

---

## 5. Auth Context

The host validates the token before forwarding requests. The common plugin receives the authenticated user identity via HTTP headers injected by the host:

| Header | Content |
|---|---|
| `X-Oasis-User-ID` | Authenticated user's UUID |
| `X-Oasis-User-Roles` | Comma-separated role list (e.g., `administrator,teacher`) |
| `X-Oasis-Ed-Org-ID` | The ed-org the user is scoped to |

The common plugin may use these headers to enforce authorization (e.g., a teacher can only read their own sections). It must not re-validate the token itself.

---

## 6. Error Handling Convention

All error responses use a consistent JSON envelope:

```json
{
  "code": "NOT_FOUND",
  "message": "Student with ID abc-123 not found"
}
```

| HTTP Status | Code | When |
|---|---|---|
| 400 | `INVALID_REQUEST` | Malformed input, missing required fields |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `CONFLICT` | Duplicate key or constraint violation |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

---

## 7. Database Convention

- The common plugin connects using `shared.OpenDatabase()` — no direct connection strings
- All tables owned by the common plugin use the prefix `edfi_`
- The common plugin never runs migrations — it reads/writes only
- Foreign key constraints are enforced (`PRAGMA foreign_keys=ON` is set by the shared helper)
- The `tables` field in `plugins.yaml` declares ownership: `edfi_`

---

## 8. Domain Dependencies

Domains have data dependencies — a section cannot exist without a course offering, which cannot exist without an ed-org. These dependencies are enforced at the database level (foreign keys) and should be respected at the API level (return `409 CONFLICT` if a dependency is missing).

See each domain LLD for its specific dependencies.

General dependency order (a domain may only reference domains above it):

```
Education Organization
  └── Student, Staff, Calendar, Program
        └── Course Catalog
              └── Section
                    └── Student Section Association, Bell Schedule
                          └── Attendance, Grades
  └── Credential (Staff dependency)
  └── Cohort, Intervention (Student dependency)
  └── Graduation Plan, Student Academic Record (Student + Calendar dependency)
  └── Post-Secondary Events (Student dependency)
  └── Assessment (Student + Section dependency)
```
