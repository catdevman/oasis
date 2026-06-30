# LLD: Post-Secondary Events Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Post-Secondary Events domain.

---

## 1. Responsibility

Tracks student activity after high school — college applications, enrollment, military service, employment, and career pathway outcomes. Required for ESSA college and career readiness reporting and CTE program outcome tracking. This is the counselor-facing domain for senior year and alumni tracking.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `PostSecondaryEvent` | An event in a student's post-secondary trajectory — application, enrollment, etc. |
| `PostSecondaryEventCategory` | Descriptor: College Application, College Acceptance, College Enrollment, Military Enlistment, Employment |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_post_secondary_events` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/post-secondary-events` | List post-secondary events |
| GET | `/ed-fi/post-secondary-events/{id}` | Get event |
| POST | `/ed-fi/post-secondary-events` | Record post-secondary event |
| PUT | `/ed-fi/post-secondary-events/{id}` | Update event |
| DELETE | `/ed-fi/post-secondary-events/{id}` | Delete event |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Student | Events reference a Student |
| Calendar | Events are scoped to a school year |

---

## 6. Key Business Rules

- A student may have multiple post-secondary events (e.g., applied to 5 colleges — one acceptance event per school)
- `postSecondaryInstitutionId` is optional — for community colleges and in-state institutions it should reference a known institution; for out-of-state or unknown institutions a name string is sufficient
- CTE program completers must have outcomes tracked here for Perkins V federal reporting — `careerPathway` and `technicalSkillAttainmentIndicator` fields are required for CTE students
- ESSA requires districts to report the percentage of graduates enrolling in post-secondary education within 16 months — this domain is the data source for that metric
