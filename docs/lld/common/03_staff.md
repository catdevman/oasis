# LLD: Staff Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Staff domain.

---

## 1. Responsibility

Defines staff identity, demographics, and their assignments to education organizations. Staff includes teachers, administrators, counselors, and support personnel. This domain covers identity and org assignment only — teaching assignments to sections are handled by the Section domain.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Staff` | Core identity — name, birth date, unique ID |
| `StaffEducationOrganizationAssignmentAssociation` | Staff role at an ed-org (e.g., Teacher at Lincoln High) |
| `StaffEducationOrganizationEmploymentAssociation` | Employment record — hire date, employment status, position |
| `StaffIdentificationCode` | External IDs (state staff ID, district ID) |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_staff` | This domain |
| `edfi_staff_education_organization_assignment_associations` | This domain |
| `edfi_staff_education_organization_employment_associations` | This domain |
| `edfi_staff_identification_codes` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/staffs` | List staff |
| GET | `/ed-fi/staffs/{id}` | Get staff member by ID |
| POST | `/ed-fi/staffs` | Create staff member |
| PUT | `/ed-fi/staffs/{id}` | Update staff member |
| DELETE | `/ed-fi/staffs/{id}` | Delete staff member |
| GET | `/ed-fi/staff-education-organization-assignment-associations` | List role assignments |
| POST | `/ed-fi/staff-education-organization-assignment-associations` | Assign staff to ed-org |
| PUT | `/ed-fi/staff-education-organization-assignment-associations/{id}` | Update assignment |
| DELETE | `/ed-fi/staff-education-organization-assignment-associations/{id}` | Remove assignment |
| GET | `/ed-fi/staff-education-organization-employment-associations` | List employment records |
| POST | `/ed-fi/staff-education-organization-employment-associations` | Create employment record |
| PUT | `/ed-fi/staff-education-organization-employment-associations/{id}` | Update employment |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Assignments and employment records reference an ed-org |
| Credential | Staff certifications reference a staff record (Credential domain depends on this one) |

---

## 6. Key Business Rules

- A `Staff` record is identity only; it has no ed-org scope until an assignment association is created
- A staff member may have assignments at multiple ed-orgs simultaneously
- Staff records are never hard-deleted if they have section teaching assignments, discipline records, or credential records
- The `staffClassification` on the assignment association determines role (Teacher, Principal, Counselor, etc.) and is used by auth context for authorization decisions in other domains
