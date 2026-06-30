-- =============================================================================
-- K12 Domain: Enrollment, Courses, Grades, Attendance
-- Version: 002
-- Description: K12-specific tables owned by the common plugin.
-- =============================================================================

CREATE TABLE IF NOT EXISTS K12StudentEnrollment (
    K12StudentEnrollmentId      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StudentPersonIdentifier     TEXT NOT NULL,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    SchoolYear                  TEXT NOT NULL,
    GradeLevel                  TEXT NOT NULL,
    EntryDate                   TEXT,
    ExitDate                    TEXT,
    UNIQUE (StudentPersonIdentifier, SchoolYear),
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT,
    CONSTRAINT chk_K12StudentEnrollment_GradeLevel CHECK (GradeLevel IN (
        'Preschool', 'Kindergarten', 'First grade', 'Second grade', 'Third grade',
        'Fourth grade', 'Fifth grade', 'Sixth grade', 'Seventh grade', 'Eighth grade',
        'Ninth grade', 'Tenth grade', 'Eleventh grade', 'Twelfth grade'
    ))
);

CREATE TABLE IF NOT EXISTS StaffEmployment (
    StaffEmploymentId           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StaffPersonIdentifier       TEXT NOT NULL,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    StartDate                   TEXT,
    EndDate                     TEXT,
    FOREIGN KEY (StaffPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Course (
    CourseCode                  TEXT NOT NULL PRIMARY KEY,
    CourseTitle                 TEXT NOT NULL,
    Description                 TEXT
);

CREATE TABLE IF NOT EXISTS CourseSection (
    CourseSectionIdentifier     TEXT NOT NULL PRIMARY KEY,
    SchoolOrganizationIdentifier TEXT NOT NULL,
    CourseCode                  TEXT NOT NULL,
    StaffPersonIdentifier       TEXT,
    Term                        TEXT NOT NULL,
    FOREIGN KEY (SchoolOrganizationIdentifier) REFERENCES Organization(OrganizationIdentifier) ON DELETE RESTRICT,
    FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode) ON DELETE RESTRICT,
    FOREIGN KEY (StaffPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS CourseSectionEnrollment (
    K12StudentEnrollmentId      INTEGER NOT NULL,
    CourseSectionIdentifier     TEXT NOT NULL,
    PRIMARY KEY (K12StudentEnrollmentId, CourseSectionIdentifier),
    FOREIGN KEY (K12StudentEnrollmentId) REFERENCES K12StudentEnrollment(K12StudentEnrollmentId) ON DELETE CASCADE,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Assignment (
    AssignmentIdentifier        TEXT NOT NULL PRIMARY KEY,
    CourseSectionIdentifier     TEXT NOT NULL,
    Title                       TEXT NOT NULL,
    Description                 TEXT,
    DueDate                     TEXT,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Grade (
    GradeId                     INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    AssignmentIdentifier        TEXT NOT NULL,
    StudentPersonIdentifier     TEXT NOT NULL,
    ResultScore                 TEXT NOT NULL,
    ResultDate                  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AssignmentIdentifier) REFERENCES Assignment(AssignmentIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS AttendanceEvent (
    AttendanceEventId           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    StudentPersonIdentifier     TEXT NOT NULL,
    EventDate                   TEXT NOT NULL,
    AttendanceEventType         TEXT NOT NULL,
    CourseSectionIdentifier     TEXT,
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (CourseSectionIdentifier) REFERENCES CourseSection(CourseSectionIdentifier) ON DELETE SET NULL,
    CONSTRAINT chk_AttendanceEvent_Type CHECK (AttendanceEventType IN ('Present', 'Unexcused Absence', 'Excused Absence', 'Tardy'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_enrollment_student ON K12StudentEnrollment (StudentPersonIdentifier);
CREATE INDEX IF NOT EXISTS idx_enrollment_school ON K12StudentEnrollment (SchoolOrganizationIdentifier);
CREATE INDEX IF NOT EXISTS idx_coursesection_course ON CourseSection (CourseCode);
CREATE INDEX IF NOT EXISTS idx_coursesection_teacher ON CourseSection (StaffPersonIdentifier);
CREATE INDEX IF NOT EXISTS idx_grade_student ON Grade (StudentPersonIdentifier);
CREATE INDEX IF NOT EXISTS idx_grade_assignment ON Grade (AssignmentIdentifier);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON AttendanceEvent (StudentPersonIdentifier, EventDate);
