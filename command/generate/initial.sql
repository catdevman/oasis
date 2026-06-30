-- =============================================================================
-- SIS Common Plugin: Initial Schema
-- Version: 0.0.2
-- Description: Adds CHECK constraints to enforce CEDS option sets for enum-like
--              fields.
-- =============================================================================

-- Enforce foreign key constraints for data integrity.
PRAGMA foreign_keys = ON;

-- =============================================================================
-- Core Tables: People and Organizations
-- =============================================================================

CREATE TABLE Person (
    -- CEDS Element: 000020 Person Identifier
    PersonIdentifier            TEXT NOT NULL PRIMARY KEY,
    FirstName                   TEXT NOT NULL,
    LastName                    TEXT NOT NULL,
    Birthdate                   TEXT,
    -- CEDS Element: 000035 Sex
    Sex                         TEXT,
    CreatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- ADDED: Enforce the CEDS option set for Sex.
    CONSTRAINT chk_Person_Sex CHECK (Sex IS NULL OR Sex IN ('Male', 'Female', 'Not Selected'))
);

CREATE TABLE Organization (
    OrganizationIdentifier      TEXT NOT NULL PRIMARY KEY,
    Name                        TEXT NOT NULL,
    Street                      TEXT,
    City                        TEXT,
    State                       TEXT,
    PostalCode                  TEXT,
    CreatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- Relationship & Role Tables
-- =============================================================================

CREATE TABLE GuardianRelationship (
    StudentPersonIdentifier     TEXT NOT NULL,
    GuardianPersonIdentifier    TEXT NOT NULL,
    -- CEDS Element: 000067 Relationship to Student
    RelationshipToStudent       TEXT NOT NULL,
    PRIMARY KEY (StudentPersonIdentifier, GuardianPersonIdentifier),
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (GuardianPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,

    -- ADDED: Enforce a common set of CEDS relationship types.
    CONSTRAINT chk_GuardianRelationship CHECK (RelationshipToStudent IN ('Mother', 'Father', 'Guardian', 'Grandparent', 'Other'))
);

CREATE TABLE K12StudentEnrollment (
    K12StudentEnrollmentId      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StudentPersonIdentifier     TEXT NOT NULL,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    SchoolYear                  TEXT NOT NULL,
    -- CEDS Element: 000168 Grade Level
    GradeLevel                  TEXT NOT NULL,
    EntryDate                   TEXT,
    ExitDate                    TEXT,
    UNIQUE (StudentPersonIdentifier, SchoolYear),
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT,

    -- ADDED: Enforce the CEDS option set for Grade Level.
    CONSTRAINT chk_K12StudentEnrollment_GradeLevel CHECK (GradeLevel IN (
        'Preschool', 'Kindergarten', 'First grade', 'Second grade', 'Third grade',
        'Fourth grade', 'Fifth grade', 'Sixth grade', 'Seventh grade', 'Eighth grade',
        'Ninth grade', 'Tenth grade', 'Eleventh grade', 'Twelfth grade'
    ))
);

CREATE TABLE StaffEmployment (
    StaffEmploymentId           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StaffPersonIdentifier       TEXT NOT NULL,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    StartDate                   TEXT,
    EndDate                     TEXT,
    FOREIGN KEY (StaffPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT
);

-- =============================================================================
-- Academic Structure Tables
-- =============================================================================

CREATE TABLE Course (
    CourseCode                  TEXT NOT NULL PRIMARY KEY,
    CourseTitle                 TEXT NOT NULL,
    Description                 TEXT
);

CREATE TABLE CourseSection (
    CourseSectionIdentifier     TEXT NOT NULL PRIMARY KEY,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    CourseCode                  TEXT NOT NULL,
    StaffPersonIdentifier       TEXT,
    Term                        TEXT NOT NULL,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT,
    FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode) ON DELETE RESTRICT,
    FOREIGN KEY (StaffPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE SET NULL
);

CREATE TABLE CourseSectionEnrollment (
    K12StudentEnrollmentId      INTEGER NOT NULL,
    CourseSectionIdentifier     TEXT NOT NULL,
    PRIMARY KEY (K12StudentEnrollmentId, CourseSectionIdentifier),
    FOREIGN KEY (K12StudentEnrollmentId) REFERENCES K12StudentEnrollment(K12StudentEnrollmentId) ON DELETE CASCADE,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE CASCADE
);

-- =============================================================================
-- Core Activity Tables
-- =============================================================================

CREATE TABLE Assignment (
    AssignmentIdentifier        TEXT NOT NULL PRIMARY KEY,
    CourseSectionIdentifier     TEXT NOT NULL,
    Title                       TEXT NOT NULL,
    Description                 TEXT,
    DueDate                     TEXT,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE CASCADE
);

CREATE TABLE Grade (
    GradeId                     INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    AssignmentIdentifier        TEXT NOT NULL,
    StudentPersonIdentifier     TEXT NOT NULL,
    ResultScore                 TEXT NOT NULL,
    ResultDate                  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AssignmentIdentifier) REFERENCES Assignment(AssignmentIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE
);

CREATE TABLE AttendanceEvent (
    AttendanceEventId           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StudentPersonIdentifier     TEXT NOT NULL,
    EventDate                   TEXT NOT NULL,
    -- CEDS Element: 000151 Attendance Event Type
    AttendanceEventType         TEXT NOT NULL,
    CourseSectionIdentifier     TEXT,
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE SET NULL,

    -- ADDED: Enforce the CEDS option set for Attendance Event Type.
    CONSTRAINT chk_AttendanceEvent_Type CHECK (AttendanceEventType IN ('Present', 'Unexcused Absence', 'Excused Absence', 'Tardy'))
);

-- =============================================================================
-- Indexes for Performance
-- =============================================================================
CREATE INDEX idx_person_name ON Person (LastName, FirstName);
CREATE INDEX idx_enrollment_student ON K12StudentEnrollment (StudentPersonIdentifier);
CREATE INDEX idx_enrollment_school ON K12StudentEnrollment (SchoolOrganizationIdentifier);
CREATE INDEX idx_coursesection_course ON CourseSection (CourseCode);
CREATE INDEX idx_coursesection_teacher ON CourseSection (StaffPersonIdentifier);
CREATE INDEX idx_grade_student ON Grade (StudentPersonIdentifier);
CREATE INDEX idx_grade_assignment ON Grade (AssignmentIdentifier);
CREATE INDEX idx_attendance_student_date ON AttendanceEvent (StudentPersonIdentifier, EventDate);
