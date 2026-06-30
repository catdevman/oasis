# LLD: Course Catalog Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Course Catalog domain.

---

## 1. Responsibility

Defines what courses exist and where/when they are offered. There are two distinct levels: `Course` (the district-level definition of a class) and `CourseOffering` (the school-and-session-level availability of that class). Sections are instances of a course offering — see the Section domain LLD.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Course` | District-wide course definition — title, code, subject, credits |
| `CourseOffering` | A course available at a specific school in a specific session |
| `LearningStandard` | Academic standards a course is aligned to (optional, supports standards-based grading) |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_courses` | This domain |
| `edfi_course_offerings` | This domain |
| `edfi_learning_standards` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/courses` | List courses |
| GET | `/ed-fi/courses/{id}` | Get course |
| POST | `/ed-fi/courses` | Create course |
| PUT | `/ed-fi/courses/{id}` | Update course |
| DELETE | `/ed-fi/courses/{id}` | Delete course |
| GET | `/ed-fi/course-offerings` | List course offerings |
| GET | `/ed-fi/course-offerings/{id}` | Get course offering |
| POST | `/ed-fi/course-offerings` | Create course offering |
| PUT | `/ed-fi/course-offerings/{id}` | Update course offering |
| DELETE | `/ed-fi/course-offerings/{id}` | Delete course offering |
| GET | `/ed-fi/learning-standards` | List learning standards |
| POST | `/ed-fi/learning-standards` | Create learning standard |
| PUT | `/ed-fi/learning-standards/{id}` | Update learning standard |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | `Course` is defined at the LEA level; `CourseOffering` is scoped to a School |
| Calendar | `CourseOffering` is scoped to a Session |

---

## 6. Key Business Rules

- A `Course` is owned by a `LocalEducationAgency` — it represents the district's master course catalog
- A `CourseOffering` links a course to a specific school and session — the same course may be offered at multiple schools in the same session
- `Course` cannot be deleted if any `CourseOffering` references it
- `CourseOffering` cannot be deleted if any `Section` references it
- `creditsEarned` on a course is the expected credit value; actual credits awarded to a student live in the Student Academic Record domain
