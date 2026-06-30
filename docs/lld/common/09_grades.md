# LLD: Grades Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Grades domain.

---

## 1. Responsibility

Records the grades a student earns in a section for a grading period. This is the core teacher-facing workflow domain — the primary differentiator from incumbent SIS products. Reliability and correctness here are non-negotiable (see RESEARCH.md: Skyward broke GPA calculations affecting college applications).

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Grade` | A student's grade in a section for a specific grading period |
| `GradeType` | Descriptor: Grading Period, Semester, Final, Exam |
| `ReportCard` | Aggregate of a student's grades for a grading period |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_grades` | This domain |
| `edfi_report_cards` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/grades` | List grades |
| GET | `/ed-fi/grades/{id}` | Get grade |
| POST | `/ed-fi/grades` | Submit grade |
| PUT | `/ed-fi/grades/{id}` | Update grade |
| DELETE | `/ed-fi/grades/{id}` | Delete grade |
| GET | `/ed-fi/report-cards` | List report cards |
| GET | `/ed-fi/report-cards/{id}` | Get report card |
| POST | `/ed-fi/report-cards` | Generate report card |
| PUT | `/ed-fi/report-cards/{id}` | Update report card |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | Grade references a Student |
| Section | Grade is earned in a Section |
| Student Section Association | Grade is only valid for an enrolled student |
| Calendar | Grade is scoped to a GradingPeriod |

---

## 6. Key Business Rules

- A `Grade` requires a valid `StudentSectionAssociation` for the student+section combination
- The `gradingPeriodReference` on a grade must be a grading period that falls within the section's session
- `letterGradeEarned` and `numericGradeEarned` are both optional individually but at least one must be present
- A student may have at most one grade per section per grading period per grade type
- GPA calculation is derived from grades — it is a read-only computed value, never stored directly. GPA computation logic must be deterministic and auditable (see RESEARCH.md: Skyward Qmlativ GPA bug)
- Teachers may only submit/update grades for sections they are assigned to
- Grade history must be preserved — updates append to an audit log, not overwrite silently
