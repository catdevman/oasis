# LLD: Assessment Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Assessment domain.

---

## 1. Responsibility

Records standardized assessment definitions and student score results. Assessment data is predominantly received from external platforms (state testing systems, NWEA MAP, i-Ready, etc.) rather than generated within OASIS. This domain is primarily an integration target — it stores what other systems produce so the SIS has a unified view of student performance.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Assessment` | Definition of an assessment — title, category, subject, max score |
| `AssessmentItem` | An individual question or component within an assessment |
| `ObjectiveAssessment` | A sub-domain or reporting category within an assessment |
| `StudentAssessment` | A student's result on a specific administration of an assessment |
| `StudentAssessmentItem` | A student's response to an individual assessment item |
| `StudentObjectiveAssessment` | A student's score on a sub-domain of an assessment |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_assessments` | This domain |
| `edfi_assessment_items` | This domain |
| `edfi_objective_assessments` | This domain |
| `edfi_student_assessments` | This domain |
| `edfi_student_assessment_items` | This domain |
| `edfi_student_objective_assessments` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/assessments` | List assessments |
| GET | `/ed-fi/assessments/{id}` | Get assessment definition |
| POST | `/ed-fi/assessments` | Create assessment definition |
| PUT | `/ed-fi/assessments/{id}` | Update assessment definition |
| DELETE | `/ed-fi/assessments/{id}` | Delete assessment definition |
| GET | `/ed-fi/student-assessments` | List student results |
| GET | `/ed-fi/student-assessments/{id}` | Get student result |
| POST | `/ed-fi/student-assessments` | Record student result |
| PUT | `/ed-fi/student-assessments/{id}` | Update student result |
| DELETE | `/ed-fi/student-assessments/{id}` | Delete student result |
| GET | `/ed-fi/objective-assessments` | List objective assessments |
| POST | `/ed-fi/objective-assessments` | Create objective assessment |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | StudentAssessment references a Student |
| Calendar | Assessment administrations are scoped to a school year |
| Education Organization | Assessment results are scoped to a School |

---

## 6. Key Business Rules

- Assessment definitions are typically created once and reused across years — `assessmentVersion` tracks the edition
- `administrationDate` on `StudentAssessment` is required — it is the primary key for identifying a specific test sitting
- Score results use `scoreResult` + `resultDatatypeType` — scores may be numeric, level (e.g., "Proficient"), or percentile; the type must match the assessment definition
- State assessments (e.g., STAAR, SBAC, PARCC) are the primary source — results will typically arrive via bulk import, not individual API calls; POST must support batch-friendly payloads
- Assessment records must never be deleted once a student result exists — amend via PUT only
- Access is read-only for teachers; administrators and counselors have full access
