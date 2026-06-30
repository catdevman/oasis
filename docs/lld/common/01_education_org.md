# LLD: Education Organization Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Education Organization domain.

---

## 1. Responsibility

Defines the organizational hierarchy of the educational system. Every other domain entity is scoped to an education organization. This domain must be seeded before any other domain can be populated.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `EducationOrganization` | Abstract base — shared attributes for all ed-org types |
| `StateEducationAgency` (SEA) | State-level authority |
| `LocalEducationAgency` (LEA) | District |
| `School` | Building / campus |
| `EducationOrganizationAddress` | Physical and mailing addresses |
| `EducationOrganizationCategory` | Classification (e.g., "Regular School", "Charter") |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_education_organizations` | This domain |
| `edfi_state_education_agencies` | This domain |
| `edfi_local_education_agencies` | This domain |
| `edfi_schools` | This domain |
| `edfi_education_organization_addresses` | This domain |
| `edfi_education_organization_categories` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/education-organizations` | List all ed-orgs |
| GET | `/ed-fi/education-organizations/{id}` | Get ed-org by ID |
| POST | `/ed-fi/education-organizations` | Create ed-org |
| PUT | `/ed-fi/education-organizations/{id}` | Update ed-org |
| DELETE | `/ed-fi/education-organizations/{id}` | Delete ed-org |
| GET | `/ed-fi/schools` | List schools |
| GET | `/ed-fi/schools/{id}` | Get school by ID |
| POST | `/ed-fi/schools` | Create school |
| PUT | `/ed-fi/schools/{id}` | Update school |
| DELETE | `/ed-fi/schools/{id}` | Delete school |
| GET | `/ed-fi/local-education-agencies` | List LEAs (districts) |
| GET | `/ed-fi/local-education-agencies/{id}` | Get LEA by ID |
| POST | `/ed-fi/local-education-agencies` | Create LEA |
| PUT | `/ed-fi/local-education-agencies/{id}` | Update LEA |
| DELETE | `/ed-fi/local-education-agencies/{id}` | Delete LEA |

---

## 5. Dependencies

None. This is the root domain — all other domains depend on it.

---

## 6. Key Business Rules

- A `School` must belong to a `LocalEducationAgency`
- A `LocalEducationAgency` must belong to a `StateEducationAgency`
- An ed-org cannot be deleted if any student, staff, or program record references it
- `educationOrganizationId` is the universal foreign key used across all other domains
