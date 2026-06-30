# LLD: Section Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Section domain.

---

## 1. Responsibility

A section is a specific instance of a course offering — it has a room, a teacher, and a schedule. Sections are the unit at which students are rostered, attendance is taken, and grades are assigned. This domain also manages which staff members teach which sections.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Section` | A class instance — course offering + location + identifier |
| `StaffSectionAssociation` | Assigns a teacher (or co-teacher) to a section |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_sections` | This domain |
| `edfi_staff_section_associations` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/sections` | List sections |
| GET | `/ed-fi/sections/{id}` | Get section |
| POST | `/ed-fi/sections` | Create section |
| PUT | `/ed-fi/sections/{id}` | Update section |
| DELETE | `/ed-fi/sections/{id}` | Delete section |
| GET | `/ed-fi/staff-section-associations` | List teacher-section assignments |
| GET | `/ed-fi/staff-section-associations/{id}` | Get assignment |
| POST | `/ed-fi/staff-section-associations` | Assign teacher to section |
| PUT | `/ed-fi/staff-section-associations/{id}` | Update assignment |
| DELETE | `/ed-fi/staff-section-associations/{id}` | Remove teacher from section |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Section is scoped to a School |
| Course Catalog | Section references a CourseOffering |
| Calendar | Section is scoped to a Session (via CourseOffering) |
| Staff | StaffSectionAssociation references a Staff record |
| Bell Schedule | Section meeting times reference Bell Schedule periods (Bell Schedule domain depends on Section) |

---

## 6. Key Business Rules

- A section must reference a valid `CourseOffering` — it cannot exist independently
- A section may have multiple staff associations (co-teaching); exactly one must be designated `primaryInstructorFlag = true`
- A section cannot be deleted if student section associations, attendance events, or grade records reference it
- The `sectionIdentifier` must be unique within a school and session
- Teachers may only be listed sections they are assigned to (enforced via `X-Oasis-User-Roles`); administrators see all sections
