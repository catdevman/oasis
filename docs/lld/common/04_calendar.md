# LLD: Calendar Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Calendar domain.

---

## 1. Responsibility

Defines the time structure of the school year: school years, sessions (terms/semesters), grading periods, and individual school days. All time-scoped data in other domains (enrollment, grades, attendance, sections) references calendar entities.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `SchoolYearType` | Descriptor for a school year (e.g., 2025-2026) |
| `Session` | A term or semester within a school year at a specific school |
| `GradingPeriod` | A subdivision of a session used for report card grades |
| `Calendar` | A named calendar for a school (may vary by student group) |
| `CalendarDate` | An individual date on a calendar with an event type (Instructional Day, Holiday, etc.) |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_school_year_types` | This domain |
| `edfi_sessions` | This domain |
| `edfi_grading_periods` | This domain |
| `edfi_calendars` | This domain |
| `edfi_calendar_dates` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/school-year-types` | List school years |
| GET | `/ed-fi/school-year-types/{id}` | Get school year |
| POST | `/ed-fi/school-year-types` | Create school year |
| GET | `/ed-fi/sessions` | List sessions |
| GET | `/ed-fi/sessions/{id}` | Get session |
| POST | `/ed-fi/sessions` | Create session |
| PUT | `/ed-fi/sessions/{id}` | Update session |
| DELETE | `/ed-fi/sessions/{id}` | Delete session |
| GET | `/ed-fi/grading-periods` | List grading periods |
| GET | `/ed-fi/grading-periods/{id}` | Get grading period |
| POST | `/ed-fi/grading-periods` | Create grading period |
| PUT | `/ed-fi/grading-periods/{id}` | Update grading period |
| DELETE | `/ed-fi/grading-periods/{id}` | Delete grading period |
| GET | `/ed-fi/calendars` | List calendars |
| GET | `/ed-fi/calendars/{id}` | Get calendar |
| POST | `/ed-fi/calendars` | Create calendar |
| GET | `/ed-fi/calendar-dates` | List calendar dates |
| POST | `/ed-fi/calendar-dates` | Add calendar date |
| DELETE | `/ed-fi/calendar-dates/{id}` | Remove calendar date |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Sessions and calendars are scoped to a School |

---

## 6. Key Business Rules

- A `Session` belongs to exactly one school and one school year
- `GradingPeriod` dates must fall within the parent session's date range
- A `CalendarDate` event type of `Instructional Day` is what counts toward attendance calculations — non-instructional days must not generate attendance expectations
- Sessions cannot be deleted if course offerings or student enrollments reference them
- Grading periods cannot be deleted if grade records reference them
- A school may have multiple calendars (e.g., standard vs. alternative program calendar)
