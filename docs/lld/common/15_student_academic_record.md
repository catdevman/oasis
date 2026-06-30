# LLD: Student Academic Record Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Student Academic Record domain.

---

## 1. Responsibility

The permanent academic record for a student — credits earned, cumulative GPA, diplomas awarded, and course transcripts. This is the long-term historical record that persists even after a student leaves a school. It is the source of truth for transcripts used in college applications and transfers.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `StudentAcademicRecord` | A student's academic record for a session — cumulative GPA, credits attempted/earned |
| `CourseTranscript` | The record of a student completing a course — grade earned, credits, school year |
| `Diploma` | Diploma or credential awarded to a student |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_student_academic_records` | This domain |
| `edfi_course_transcripts` | This domain |
| `edfi_diplomas` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/student-academic-records` | List academic records |
| GET | `/ed-fi/student-academic-records/{id}` | Get academic record |
| POST | `/ed-fi/student-academic-records` | Create academic record |
| PUT | `/ed-fi/student-academic-records/{id}` | Update academic record |
| GET | `/ed-fi/course-transcripts` | List transcript entries |
| GET | `/ed-fi/course-transcripts/{id}` | Get transcript entry |
| POST | `/ed-fi/course-transcripts` | Add transcript entry |
| PUT | `/ed-fi/course-transcripts/{id}` | Update transcript entry |
| GET | `/ed-fi/diplomas` | List diplomas |
| POST | `/ed-fi/diplomas` | Award diploma |
| PUT | `/ed-fi/diplomas/{id}` | Update diploma |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | Records are scoped to a Student |
| Education Organization | Records are scoped to a School |
| Calendar | Records are scoped to a Session or school year |
| Course Catalog | CourseTranscript references a Course |
| Grades | Grade data informs what is written to the transcript (but transcript is the permanent record) |

---

## 6. Key Business Rules

- `StudentAcademicRecord` is created once per student per session — it is the session-level rollup
- `CourseTranscript` is the permanent record of completing a course and must never be deleted after a diploma is awarded
- `cumulativeGradePointsEarned` and `cumulativeGradePointAverage` on the academic record are computed values that must be recalculated when grades change — they are stored for performance but must be kept in sync
- Transcripts must be exportable — a future spec will define a PDF/structured export endpoint
- Students have read access to their own academic records; parents have read access to their minor children's records
- Records from previous schools (transfer students) should be importable via POST — the `educationOrganizationReference` will point to the originating school
