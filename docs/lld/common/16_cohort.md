# LLD: Cohort Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Cohort domain.

---

## 1. Responsibility

Defines named groupings of students outside of formal enrollment. Cohorts are used for intervention tracking, federal graduation rate reporting (the 4-year cohort graduation rate is a federal ESSA metric), and any ad-hoc grouping a school needs (e.g., "At-Risk Students", "NHS Members").

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Cohort` | A named group of students at an ed-org |
| `StudentCohortAssociation` | Links a student to a cohort with begin/end dates |
| `StaffCohortAssociation` | Links a staff member to a cohort (e.g., the counselor responsible) |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_cohorts` | This domain |
| `edfi_student_cohort_associations` | This domain |
| `edfi_staff_cohort_associations` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/cohorts` | List cohorts |
| GET | `/ed-fi/cohorts/{id}` | Get cohort |
| POST | `/ed-fi/cohorts` | Create cohort |
| PUT | `/ed-fi/cohorts/{id}` | Update cohort |
| DELETE | `/ed-fi/cohorts/{id}` | Delete cohort |
| GET | `/ed-fi/student-cohort-associations` | List student-cohort memberships |
| POST | `/ed-fi/student-cohort-associations` | Add student to cohort |
| PUT | `/ed-fi/student-cohort-associations/{id}` | Update membership |
| DELETE | `/ed-fi/student-cohort-associations/{id}` | Remove student from cohort |
| GET | `/ed-fi/staff-cohort-associations` | List staff-cohort links |
| POST | `/ed-fi/staff-cohort-associations` | Link staff to cohort |
| DELETE | `/ed-fi/staff-cohort-associations/{id}` | Remove staff from cohort |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Cohorts are scoped to an ed-org |
| Student | StudentCohortAssociation references a Student |
| Staff | StaffCohortAssociation references a Staff record |

---

## 6. Key Business Rules

- `cohortType` descriptor controls semantics: `Academic Intervention`, `Attendance Intervention`, `Extracurricular`, `Field Set`, `Other` — the federal graduation cohort uses `Field Set`
- A student may belong to multiple cohorts simultaneously
- The federal 4-year cohort graduation rate is computed from students in the entering 9th-grade cohort — this cohort must be maintained accurately for ESSA reporting
- Cohorts may be staff-managed (a counselor owns a caseload cohort) or system-generated (at-risk flags from attendance/grade data)
