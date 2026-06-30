# LLD: Student Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Student domain.

---

## 1. Responsibility

Defines student identity, demographics, and enrollment in schools. This is the core subject entity of the SIS — nearly every other domain associates data back to a student.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Student` | Core identity — name, birth date, unique ID |
| `StudentSchoolAssociation` | Enrollment of a student at a school for a school year |
| `StudentEducationOrganizationAssociation` | Demographics, race, gender, language, disability flags scoped to an ed-org |
| `StudentIdentificationCode` | External IDs (state student ID, district ID, etc.) |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_students` | This domain |
| `edfi_student_school_associations` | This domain |
| `edfi_student_education_organization_associations` | This domain |
| `edfi_student_identification_codes` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/students` | List students |
| GET | `/ed-fi/students/{id}` | Get student by ID |
| POST | `/ed-fi/students` | Create student |
| PUT | `/ed-fi/students/{id}` | Update student |
| DELETE | `/ed-fi/students/{id}` | Delete student |
| GET | `/ed-fi/student-school-associations` | List enrollments |
| GET | `/ed-fi/student-school-associations/{id}` | Get enrollment |
| POST | `/ed-fi/student-school-associations` | Enroll student in school |
| PUT | `/ed-fi/student-school-associations/{id}` | Update enrollment |
| DELETE | `/ed-fi/student-school-associations/{id}` | Withdraw student |
| GET | `/ed-fi/student-education-organization-associations` | List demographic associations |
| POST | `/ed-fi/student-education-organization-associations` | Create demographic record |
| PUT | `/ed-fi/student-education-organization-associations/{id}` | Update demographics |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | `StudentSchoolAssociation` references a School; `StudentEducationOrganizationAssociation` references an ed-org |
| Calendar | Enrollment is scoped to a school year (session) |

---

## 6. Key Business Rules

- A `Student` record represents identity only — it has no ed-org scope by itself
- Enrollment (`StudentSchoolAssociation`) is what places a student at a school for a given year; a student may be enrolled at multiple schools simultaneously (e.g., part-time CTE)
- Demographics are stored on `StudentEducationOrganizationAssociation`, not on `Student` directly — this allows demographics to vary by ed-org context
- Student records are never hard-deleted if they have associated attendance, grades, or discipline records — soft delete or withdrawal only
- FERPA applies: student records may only be accessed by users scoped to the student's enrolled ed-org (`X-Oasis-Ed-Org-ID` header)
