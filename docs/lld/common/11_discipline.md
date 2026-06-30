# LLD: Discipline Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Discipline domain.

---

## 1. Responsibility

Records disciplinary incidents and the actions taken in response. This domain supports federal Civil Rights Data Collection (CRDC) reporting, IDEA discipline reporting for special education students, and district-level behavior tracking.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `DisciplineIncident` | An incident — date, location, description, behavior type |
| `StudentDisciplineIncidentBehaviorAssociation` | Links a student to an incident as a participant |
| `DisciplineAction` | The consequence applied — suspension, expulsion, detention, etc. |
| `StudentDisciplineIncidentNonOffenderAssociation` | Links a student to an incident as a victim or witness |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_discipline_incidents` | This domain |
| `edfi_student_discipline_incident_behavior_associations` | This domain |
| `edfi_discipline_actions` | This domain |
| `edfi_student_discipline_incident_non_offender_associations` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/discipline-incidents` | List incidents |
| GET | `/ed-fi/discipline-incidents/{id}` | Get incident |
| POST | `/ed-fi/discipline-incidents` | Create incident |
| PUT | `/ed-fi/discipline-incidents/{id}` | Update incident |
| DELETE | `/ed-fi/discipline-incidents/{id}` | Delete incident |
| GET | `/ed-fi/student-discipline-incident-behavior-associations` | List student-incident links |
| POST | `/ed-fi/student-discipline-incident-behavior-associations` | Link student to incident |
| PUT | `/ed-fi/student-discipline-incident-behavior-associations/{id}` | Update student role |
| GET | `/ed-fi/discipline-actions` | List discipline actions |
| POST | `/ed-fi/discipline-actions` | Record discipline action |
| PUT | `/ed-fi/discipline-actions/{id}` | Update action |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Incidents are scoped to a School |
| Student | Associations reference Student records |
| Staff | Incident reporter references a Staff record |

---

## 6. Key Business Rules

- A `DisciplineIncident` may involve multiple students (offenders, victims, witnesses) — each is a separate association record
- `DisciplineAction` duration in days is required for suspensions and expulsions — this feeds CRDC reporting
- For Special Education students, any suspension over 10 cumulative days in a school year triggers IDEA manifestation determination requirements — this must be trackable via this domain's data
- Discipline records are sensitive — access must be restricted to administrators and the student's own counselor/case manager
- Incidents are never hard-deleted; they may be amended via PUT
