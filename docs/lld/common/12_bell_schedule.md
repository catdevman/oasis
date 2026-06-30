# LLD: Bell Schedule Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Bell Schedule domain.

---

## 1. Responsibility

Defines the period structure of the school day and maps sections to specific meeting times. This is the operational scheduling layer — it answers "when does this section meet?" Bell schedules enable period-level attendance, substitute tracking, and timetable display.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `BellSchedule` | A named schedule for a school (e.g., "Regular Day", "A Day", "B Day") |
| `ClassPeriod` | A named period within a school day (e.g., "Period 1", "Block A") |
| `SectionClassPeriod` | Links a Section to a ClassPeriod within a BellSchedule |
| `BellScheduleDate` | Assigns a BellSchedule to a specific calendar date |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_bell_schedules` | This domain |
| `edfi_class_periods` | This domain |
| `edfi_section_class_periods` | This domain |
| `edfi_bell_schedule_dates` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/bell-schedules` | List bell schedules |
| GET | `/ed-fi/bell-schedules/{id}` | Get bell schedule |
| POST | `/ed-fi/bell-schedules` | Create bell schedule |
| PUT | `/ed-fi/bell-schedules/{id}` | Update bell schedule |
| DELETE | `/ed-fi/bell-schedules/{id}` | Delete bell schedule |
| GET | `/ed-fi/class-periods` | List class periods |
| POST | `/ed-fi/class-periods` | Create class period |
| PUT | `/ed-fi/class-periods/{id}` | Update class period |
| DELETE | `/ed-fi/class-periods/{id}` | Delete class period |
| GET | `/ed-fi/section-class-periods` | List section-period mappings |
| POST | `/ed-fi/section-class-periods` | Map section to period |
| DELETE | `/ed-fi/section-class-periods/{id}` | Remove mapping |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Bell schedules are scoped to a School |
| Section | SectionClassPeriod references a Section |
| Calendar | BellScheduleDate references a CalendarDate |

---

## 6. Key Business Rules

- A school may have multiple bell schedules (e.g., A/B alternating day, early release) — each is a distinct `BellSchedule`
- A section may meet in multiple periods (e.g., a double-period lab) — multiple `SectionClassPeriod` records are valid
- `BellScheduleDate` maps a specific calendar date to a schedule — this is how the system knows which schedule is active on any given day
- A class period cannot be deleted if any section is mapped to it
