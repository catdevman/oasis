# LLD: Program Domain

> **Document hierarchy:**
> - Grandparent: [HLD.md](../../../HLD.md)
> - Parent: [Common Plugin LLD](../common.md)
>
> All conventions (routes, errors, auth context, DB) are defined in the parent LLD.
> This document covers only what is specific to the Program domain.

---

## 1. Responsibility

Defines special programs that students may participate in and records student participation in those programs. Programs include federally mandated categories (Special Education, English Language Learners, Title I, CTE) and district-defined programs. Federal compliance reporting depends heavily on this domain.

---

## 2. Ed-Fi Entities

| Entity | Description |
|---|---|
| `Program` | Definition of a special program at an ed-org |
| `StudentProgramAssociation` | Enrollment of a student in a program with begin/end dates |
| `StudentSpecialEducationProgramAssociation` | Special Ed extension — IEP details, disability category, service hours |
| `StudentLanguageInstructionProgramAssociation` | ELL extension — language proficiency, entry/exit criteria |
| `StudentTitleIPartAProgramAssociation` | Title I extension — program service type |
| `StudentCTEProgramAssociation` | CTE extension — technical skill attainment, non-traditional completion |

---

## 3. Database Tables

| Table | Owned By |
|---|---|
| `edfi_programs` | This domain |
| `edfi_student_program_associations` | This domain |
| `edfi_student_special_education_program_associations` | This domain |
| `edfi_student_language_instruction_program_associations` | This domain |
| `edfi_student_title_i_part_a_program_associations` | This domain |
| `edfi_student_cte_program_associations` | This domain |

---

## 4. Routes

| Method | Path | Description |
|---|---|---|
| GET | `/ed-fi/programs` | List programs |
| GET | `/ed-fi/programs/{id}` | Get program |
| POST | `/ed-fi/programs` | Create program |
| PUT | `/ed-fi/programs/{id}` | Update program |
| DELETE | `/ed-fi/programs/{id}` | Delete program |
| GET | `/ed-fi/student-program-associations` | List student program enrollments |
| GET | `/ed-fi/student-program-associations/{id}` | Get enrollment |
| POST | `/ed-fi/student-program-associations` | Enroll student in program |
| PUT | `/ed-fi/student-program-associations/{id}` | Update enrollment |
| DELETE | `/ed-fi/student-program-associations/{id}` | Remove student from program |
| GET | `/ed-fi/student-special-education-program-associations` | List Special Ed enrollments |
| POST | `/ed-fi/student-special-education-program-associations` | Create Special Ed record |
| PUT | `/ed-fi/student-special-education-program-associations/{id}` | Update Special Ed record |
| GET | `/ed-fi/student-language-instruction-program-associations` | List ELL enrollments |
| POST | `/ed-fi/student-language-instruction-program-associations` | Create ELL record |
| PUT | `/ed-fi/student-language-instruction-program-associations/{id}` | Update ELL record |

---

## 5. Dependencies

| Domain | Why |
|---|---|
| Education Organization | Programs are defined at an ed-org level |
| Student | Student program associations reference a Student |
| Calendar | Program participation is scoped to a school year |

---

## 6. Key Business Rules

- A `Program` is defined at an ed-org level — the same program type (e.g., Special Education) must be defined separately at each ed-org that offers it
- Program type descriptors must align with federal IDEA/ESEA categories for compliance reporting
- Special Education records must include a disability category and IEP dates — these are required for IDEA Part B reporting
- ELL enrollment/exit dates are required for Title III reporting
- A student may participate in multiple programs simultaneously
- Program records are never hard-deleted — end dates are set when participation ends; the history is required for federal audit
