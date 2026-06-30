# LLD: Credential Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Credential domain.

---

## 1. Responsibility

Records staff certifications, licenses, and endorsements. Required for ESSA "highly qualified teacher" compliance reporting and for verifying that staff are credentialed for the subjects and grade levels they teach.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Credential` | A certification or license held by a staff member |
| `StaffCredential` | Links a staff member to a credential |
| `CredentialFieldDescriptor` | The subject area the credential covers |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_credentials` | This domain |
| `edfi_staff_credentials` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/credentials` | List credentials |
| GET | `/ed-fi/credentials/{id}` | Get credential |
| POST | `/ed-fi/credentials` | Create credential |
| PUT | `/ed-fi/credentials/{id}` | Update credential |
| DELETE | `/ed-fi/credentials/{id}` | Delete credential |
| GET | `/ed-fi/staff-credentials` | List staff-credential links |
| POST | `/ed-fi/staff-credentials` | Link credential to staff |
| DELETE | `/ed-fi/staff-credentials/{id}` | Remove credential from staff |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Staff | StaffCredential references a Staff record |

---

## 6. Key Business Rules

- A credential has an `expirationDate` — expired credentials must be flagged but not deleted (historical record required for audits)
- `credentialType` must be one of: `Certification`, `Licensure`, `Permit`, `Registration`
- A staff member may hold multiple credentials covering different subjects or grade bands
- For ESSA reporting, the system must be able to determine whether a teacher is "highly qualified" for each section they teach — this requires comparing their credentials against the subject area of their assigned sections
