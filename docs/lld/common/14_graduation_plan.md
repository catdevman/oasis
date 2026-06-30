# LLD: Graduation Plan Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Graduation Plan domain.

---

## 1. Responsibility

Defines graduation requirements and tracks each student's plan for meeting them. This is the counselor's primary planning tool. It answers "what does a student need to graduate, and are they on track?" Incumbents have significant failures in this area — Skyward's Qmlativ launch broke class rank visibility for seniors.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `GraduationPlan` | A template defining credit requirements by subject area for a cohort/year |
| `StudentGraduationPlanAssociation` | Links a student to a graduation plan and tracks their progress |
| `GraduationPlanCreditsBySubject` | Credit minimums by subject area within a plan |
| `GraduationPlanCreditsByCourse` | Specific required courses within a plan |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_graduation_plans` | This domain |
| `edfi_student_graduation_plan_associations` | This domain |
| `edfi_graduation_plan_credits_by_subject` | This domain |
| `edfi_graduation_plan_credits_by_course` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/graduation-plans` | List graduation plans |
| GET | `/ed-fi/graduation-plans/{id}` | Get graduation plan |
| POST | `/ed-fi/graduation-plans` | Create graduation plan |
| PUT | `/ed-fi/graduation-plans/{id}` | Update graduation plan |
| DELETE | `/ed-fi/graduation-plans/{id}` | Delete graduation plan |
| GET | `/ed-fi/student-graduation-plan-associations` | List student plan assignments |
| GET | `/ed-fi/student-graduation-plan-associations/{id}` | Get student plan |
| POST | `/ed-fi/student-graduation-plan-associations` | Assign plan to student |
| PUT | `/ed-fi/student-graduation-plan-associations/{id}` | Update student plan |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Graduation plans are defined at LEA or School level |
| Student | Student graduation plan associations reference a Student |
| Calendar | Plans are tied to an expected graduation school year |
| Course Catalog | Required courses reference Course records |
| Student Academic Record | Credit completion is read from the academic record to compute progress |

---

## 6. Key Business Rules

- A `GraduationPlan` is a template — multiple students share the same plan; individual adjustments are on the `StudentGraduationPlanAssociation`
- Credit progress is computed by reading `StudentAcademicRecord` credit data — it is never stored redundantly on the plan association
- Class rank is a derived value computed from GPA across students sharing the same graduation plan and school — it must never be cached or stored directly (see RESEARCH.md: Skyward class rank bug)
- A graduation plan cannot be deleted if any student is assigned to it
- Counselors may view and edit graduation plans for students at their assigned ed-org; students may view their own plan (read-only)
