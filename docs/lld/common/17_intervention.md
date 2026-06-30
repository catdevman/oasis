# LLD: Intervention Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Intervention domain.

---

## 1. Responsibility

Documents academic and behavioral interventions delivered to students — the RTI (Response to Intervention) and MTSS (Multi-Tiered System of Supports) workflow. Records what intervention was delivered, by whom, for how long, and what the outcome was. Increasingly required for Special Education eligibility documentation.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Intervention` | Definition of an intervention program at an ed-org |
| `InterventionStudy` | A study or structured delivery of an intervention |
| `StudentInterventionAssociation` | Links a student to an intervention with dosage and outcome |
| `StudentInterventionAttendanceEvent` | Attendance at a specific intervention session |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_interventions` | This domain |
| `edfi_intervention_studies` | This domain |
| `edfi_student_intervention_associations` | This domain |
| `edfi_student_intervention_attendance_events` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/interventions` | List interventions |
| GET | `/ed-fi/interventions/{id}` | Get intervention |
| POST | `/ed-fi/interventions` | Create intervention |
| PUT | `/ed-fi/interventions/{id}` | Update intervention |
| DELETE | `/ed-fi/interventions/{id}` | Delete intervention |
| GET | `/ed-fi/student-intervention-associations` | List student enrollments in interventions |
| POST | `/ed-fi/student-intervention-associations` | Enroll student in intervention |
| PUT | `/ed-fi/student-intervention-associations/{id}` | Update enrollment / record outcome |
| DELETE | `/ed-fi/student-intervention-associations/{id}` | Remove student from intervention |
| GET | `/ed-fi/student-intervention-attendance-events` | List attendance at intervention sessions |
| POST | `/ed-fi/student-intervention-attendance-events` | Record session attendance |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Interventions are defined at an ed-org level |
| Student | Student associations reference a Student |
| Staff | Interventions reference the delivering staff member |

---

## 6. Key Business Rules

- `interventionClass` descriptor indicates tier: `Curriculum`, `Behavioral`, `Enrichment`, `Extended Learning` — maps to RTI Tier 1/2/3
- `dosage` (total minutes delivered) on the student association is required — this is the primary evidence of intervention fidelity for Special Ed eligibility
- Outcomes must be recorded when an intervention ends — `interventionEffectiveness` is required for closure
- Intervention records are critical documentation for Special Education referrals — they must never be deleted
