-- SQLite DDL for a CEDS-compliant Student Information System with requested entities

-- Enable foreign key support in SQLite
PRAGMA foreign_keys = ON;

-- Table: Organization (generic entity for schools, districts, etc.)
CREATE TABLE Organization (
    OrganizationId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    OrganizationType TEXT NOT NULL, -- e.g., 'School', 'District'
    Identifier TEXT UNIQUE, -- NCES ID or local identifier
    Address TEXT,
    City TEXT,
    StateCode TEXT, -- e.g., 'CA', 'NY'
    PostalCode TEXT
);

-- Table: School (specific to  schools, extends Organization)
CREATE TABLE School (
    SchoolId INTEGER PRIMARY KEY,
    OrganizationId INTEGER NOT NULL,
    SchoolCategory TEXT, -- e.g., 'Elementary', 'High School'
    GradeLevelsOffered TEXT, -- e.g., 'KG-05', '09-12'
    OperationalStatus TEXT, -- e.g., 'Open', 'Closed'
    FOREIGN KEY (OrganizationId) REFERENCES Organization(OrganizationId) ON DELETE CASCADE
);

-- Table: Person (generic entity for all individuals)
CREATE TABLE Person (
    PersonId INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    MiddleName TEXT,
    BirthDate TEXT, -- 'YYYY-MM-DD'
    Sex TEXT, -- e.g., 'Male', 'Female'
    Identifier TEXT UNIQUE -- Unique ID (e.g., student ID, staff ID)
);

-- Table: Student (student-specific data)
CREATE TABLE Student (
    StudentId INTEGER PRIMARY KEY,
    PersonId INTEGER NOT NULL,
    GradeLevel TEXT, -- e.g., 'KG', '09'
    EnrollmentStatus TEXT, -- e.g., 'Active', 'Withdrawn'
    DisabilityStatus TEXT, -- e.g., 'Yes', 'No'
    EnglishProficiency TEXT, -- e.g., 'ELL', 'Fluent'
    FOREIGN KEY (PersonId) REFERENCES Person(PersonId) ON DELETE CASCADE
);

-- Table: ParentGuardian (parent/guardian-specific data)
CREATE TABLE ParentGuardian (
    ParentGuardianId INTEGER PRIMARY KEY,
    PersonId INTEGER NOT NULL,
    RelationshipType TEXT, -- e.g., 'Mother', 'Guardian'
    EmergencyContactPriority INTEGER, -- e.g., 1 for primary contact
    FOREIGN KEY (PersonId) REFERENCES Person(PersonId) ON DELETE CASCADE
);

-- Table: StudentParent (relationship between students and parents/guardians)
CREATE TABLE StudentParent (
    StudentParentId INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentId INTEGER NOT NULL,
    ParentGuardianId INTEGER NOT NULL,
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE,
    FOREIGN KEY (ParentGuardianId) REFERENCES ParentGuardian(ParentGuardianId) ON DELETE CASCADE
);

-- Table: Staff (staff-specific data)
CREATE TABLE Staff (
    StaffId INTEGER PRIMARY KEY,
    PersonId INTEGER NOT NULL,
    PositionTitle TEXT, -- e.g., 'Teacher', 'Principal'
    HireDate TEXT, -- 'YYYY-MM-DD'
    EmploymentStatus TEXT, -- e.g., 'Full-time', 'Part-time'
    FOREIGN KEY (PersonId) REFERENCES Person(PersonId) ON DELETE CASCADE
);

-- Table: Course (course catalog)
CREATE TABLE Course (
    CourseId INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseCode TEXT NOT NULL, -- CEDS course code
    CourseTitle TEXT NOT NULL,
    Description TEXT,
    Subject TEXT -- e.g., 'Math', 'Science'
);

-- Table: CourseSection (specific sections of a course)
CREATE TABLE CourseSection (
    SectionId INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseId INTEGER NOT NULL,
    SchoolId INTEGER NOT NULL,
    SectionIdentifier TEXT NOT NULL, -- Unique within school, e.g., 'Math101-A'
    StaffId INTEGER, -- Teacher assigned to section
    SchoolYear TEXT, -- e.g., '2024-2025'
    Period TEXT, -- e.g., 'Period 1'
    FOREIGN KEY (CourseId) REFERENCES Course(CourseId) ON DELETE CASCADE,
    FOREIGN KEY (SchoolId) REFERENCES School(SchoolId) ON DELETE CASCADE,
    FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON DELETE SET NULL
);

-- Table: StudentEnrollment (student enrollment in a school)
CREATE TABLE StudentEnrollment (
    EnrollmentId INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentId INTEGER NOT NULL,
    SchoolId INTEGER NOT NULL,
    EntryDate TEXT NOT NULL, -- 'YYYY-MM-DD'
    ExitDate TEXT, -- 'YYYY-MM-DD', nullable
    SchoolYear TEXT, -- e.g., '2024-2025'
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE,
    FOREIGN KEY (SchoolId) REFERENCES School(SchoolId) ON DELETE CASCADE
);

-- Table: StudentCourseSection (student enrollment in course sections)
CREATE TABLE StudentCourseSection (
    StudentCourseSectionId INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentId INTEGER NOT NULL,
    SectionId INTEGER NOT NULL,
    EnrollmentId INTEGER NOT NULL,
    GradeEarned TEXT, -- e.g., 'A', 'B-'
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE,
    FOREIGN KEY (SectionId) REFERENCES CourseSection(SectionId) ON DELETE CASCADE,
    FOREIGN KEY (EnrollmentId) REFERENCES StudentEnrollment(EnrollmentId) ON DELETE CASCADE
);

-- Table: Incident (disciplinary or safety incidents)
CREATE TABLE Incident (
    IncidentId INTEGER PRIMARY KEY AUTOINCREMENT,
    SchoolId INTEGER NOT NULL,
    IncidentDate TEXT NOT NULL, -- 'YYYY-MM-DD'
    IncidentType TEXT, -- e.g., 'Disciplinary', 'Safety'
    Description TEXT,
    FOREIGN KEY (SchoolId) REFERENCES School(SchoolId) ON DELETE CASCADE
);

-- Table: StudentIncident (links students to incidents)
CREATE TABLE StudentIncident (
    StudentIncidentId INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentId INTEGER NOT NULL,
    IncidentId INTEGER NOT NULL,
    Role TEXT, -- e.g., 'Offender', 'Victim', 'Witness'
    ActionTaken TEXT, -- e.g., 'Suspension', 'Warning'
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE,
    FOREIGN KEY (IncidentId) REFERENCES Incident(IncidentId) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_enrollment_student ON StudentEnrollment(StudentId);
CREATE INDEX idx_studentcourse_section ON StudentCourseSection(StudentId);
CREATE INDEX idx_incident_school ON Incident(SchoolId);
CREATE INDEX idx_studentincident_student ON StudentIncident(StudentId);
