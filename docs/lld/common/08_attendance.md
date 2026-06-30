# LLD: Attendance Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Attendance domain.

---

## 1. Responsibility

Records student presence or absence at two levels: daily (school-level) and period (section-level). Attendance data is federally reported and drives state funding calculations in most states. This domain is one of the highest-frequency write domains in the system.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `StudentSchoolAttendanceEvent` | Daily attendance — present, absent, tardy at the school level |
| `StudentSectionAttendanceEvent` | Period attendance — presence in a specific section on a specific date |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_student_school_attendance_events` | This domain |
| `edfi_student_section_attendance_events` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/student-school-attendance-events` | List daily attendance events |
| GET | `/ed-fi/student-school-attendance-events/{id}` | Get daily event |
| POST | `/ed-fi/student-school-attendance-events` | Record daily attendance |
| PUT | `/ed-fi/student-school-attendance-events/{id}` | Correct daily attendance |
| DELETE | `/ed-fi/student-school-attendance-events/{id}` | Delete attendance event |
| GET | `/ed-fi/student-section-attendance-events` | List section attendance events |
| GET | `/ed-fi/student-section-attendance-events/{id}` | Get section event |
| POST | `/ed-fi/student-section-attendance-events` | Record section attendance |
| PUT | `/ed-fi/student-section-attendance-events/{id}` | Correct section attendance |
| DELETE | `/ed-fi/student-section-attendance-events/{id}` | Delete section attendance event |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | Attendance events reference a Student |
| Education Organization | School attendance events are scoped to a School |
| Section | Section attendance events reference a Section |
| Student Section Association | Section attendance is only valid for enrolled students |
| Calendar | Attendance events must fall on a CalendarDate marked as an Instructional Day |

---

## 6. Key Business Rules

- Attendance events may only be recorded on dates that are `Instructional Day` calendar dates — attempts to record on holidays or weekends must return `400 INVALID_REQUEST`
- A student may only have one school-level attendance event per date per school
- A student may only have one section-level attendance event per section per date
- Valid `attendanceEventCategory` values: `In Attendance`, `Excused Absence`, `Unexcused Absence`, `Tardy`, `Early Departure`
- Retroactive corrections (PUT) must be permitted — teachers frequently correct prior-day attendance
- Attendance events are never deleted for audit purposes; corrections use PUT to update the category
