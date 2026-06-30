# LLD: Student Section Association Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Student Section Association domain.

---

## 1. Responsibility

Enrolls students into sections. This is the gradebook roster — the definitive record of which students are in which class. Attendance events and section grades are only valid for students with an active section association.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `StudentSectionAssociation` | Links a student to a section with begin/end dates and enrollment status |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_student_section_associations` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/student-section-associations` | List roster entries |
| GET | `/ed-fi/student-section-associations/{id}` | Get roster entry |
| POST | `/ed-fi/student-section-associations` | Enroll student in section |
| PUT | `/ed-fi/student-section-associations/{id}` | Update enrollment (e.g., set end date) |
| DELETE | `/ed-fi/student-section-associations/{id}` | Remove student from section |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | Association references a Student record |
| Section | Association references a Section |
| Calendar | Enrollment begin/end dates must fall within the section's session dates |

---

## 6. Key Business Rules

- A student must have an active `StudentSchoolAssociation` at the section's school before being enrolled in a section
- `beginDate` is required; `endDate` is set when a student is withdrawn from the section mid-term
- Attendance and grade records for a student+section are only valid between the student's `beginDate` and `endDate` for that association
- A student may not be enrolled in two sections of the same course offering in the same session without an explicit override
- Teachers see only students enrolled in their assigned sections; administrators see all
