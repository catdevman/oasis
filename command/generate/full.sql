-- SQLite DDL for CEDS By Domain schema
-- Notes:
-- - Data types are assumed based on element definitions:
--   - TEXT for identifiers, names, descriptions, language codes, and dates (SQLite lacks DATE type).
--   - INTEGER for sequence numbers, counts, or numeric codes.
--   - REAL for weights, percentages, or monetary values.
-- - Primary keys inferred from unique identifiers (e.g., AssessmentIdentifier, JobIdentifier).
-- - Foreign keys inferred where identifiers are shared across entities.
-- - CountryCode uses a lookup table due to large option set (200+ values).
-- - Enable foreign keys in SQLite with: PRAGMA foreign_keys = ON;

-- Creating table for Calendar entity
CREATE TABLE Calendar (
    CalendarCode TEXT NOT NULL, -- Unique district-assigned calendar code, follows XSD:Token format
    CalendarDescription TEXT, -- Description or identification of the calendar
    SchoolYear INTEGER, -- Four-digit year-end for academic year (e.g., 2013 for 2012-2013)
    SessionCode TEXT, -- Local code for session/term, follows XSD:Token format
    SessionDescription TEXT, -- Short description of the session
    SessionBeginDate DATE, -- Date session begins
    SessionEndDate DATE, -- Date session ends
    SessionStartTime TEXT, -- Time session begins (HH:MM:SS)
    SessionEndTime TEXT, -- Time session ends (HH:MM:SS)
    SessionAttendanceTermIndicator TEXT CHECK (SessionAttendanceTermIndicator IN ('Yes', 'No')),
    SessionMarkingTermIndicator TEXT CHECK (SessionMarkingTermIndicator IN ('Yes', 'No')),
    SessionSchedulingTermIndicator TEXT CHECK (SessionSchedulingTermIndicator IN ('Yes', 'No')),
    SessionType TEXT CHECK (SessionType IN (
        'FullSchoolYear', -- Full School Year
        'Intersession', -- Intersession
        'LongSession', -- Long Session
        'MiniTerm', -- Mini Term
        'Quarter', -- Quarter
        'Quinmester', -- Quinmester
        'Semester', -- Semester
        'SummerTerm', -- Summer Term
        'Trimester', -- Trimester
        'TwelveMonth', -- Twelve Month
        'Other' -- Other
    )),
    AlternateDayName TEXT, -- Alternate name for school day (e.g., Blue day)
    SessionSequenceNumber INTEGER -- Position in sequence of sessions
);

-- Creating table for Calendar Event entity
CREATE TABLE CalendarEvent (
    CalendarCode TEXT NOT NULL, -- References Calendar table
    CalendarEventDate DATE, -- Date of the event
    CalendarEventDayName TEXT, -- Name used for the event day
    CalendarEventType TEXT CHECK (CalendarEventType IN (
        'EmergencyDay', -- Emergency day
        'Holiday', -- Holiday
        'InstructionalDay', -- Instructional day
        'Other', -- Other
        'Strike', -- Strike
        'LateArrivalEarlyDismissal', -- Student late arrival/early dismissal
        'TeacherOnlyDay' -- Teacher only day
    )),
    StartTime TEXT, -- Starting time (HH:MM:SS)
    EndTime TEXT -- Ending time (HH:MM:SS)
);

-- Creating table for Calendar Crisis entity
CREATE TABLE CalendarCrisis (
    CalendarCode TEXT NOT NULL, -- References Calendar table
    CrisisCode TEXT NOT NULL, -- Unique crisis identifier, follows XSD:Token format
    CrisisName TEXT, -- Name of the crisis
    CrisisDescription TEXT, -- Description of the crisis
    CrisisType TEXT, -- Type or category of crisis
    CrisisStartDate DATE, -- Date crisis affected agency
    CrisisEndDate DATE -- Date crisis ceased affecting agency
);

-- Creating table for Course Section entity
CREATE TABLE CourseSection (
    CourseSectionIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    CourseIdentifier TEXT, -- References Course table, follows XSD:Token format
    ClassroomIdentifier TEXT, -- Unique room identifier, follows XSD:Token format
    ClassBeginningTime TEXT, -- Time class begins (HH:MM:SS)
    ClassEndingTime TEXT, -- Time class ends (HH:MM:SS)
    ClassMeetingDays TEXT, -- Days class meets
    ClassPeriod TEXT, -- Portion of daily session
    SessionCode TEXT, -- Local code for session/term
    SessionDescription TEXT, -- Short session description
    SessionDesignator TEXT, -- Academic session identifier
    SessionBeginDate DATE, -- Session start date
    SessionEndDate DATE, -- Session end date
    SessionAttendanceTermIndicator TEXT CHECK (SessionAttendanceTermIndicator IN ('Yes', 'No')),
    SessionMarkingTermIndicator TEXT CHECK (SessionMarkingTermIndicator IN ('Yes', 'No')),
    SessionSchedulingTermIndicator TEXT CHECK (SessionSchedulingTermIndicator IN ('Yes', 'No')),
    SessionType TEXT CHECK (SessionType IN (
        'FullSchoolYear', -- Full School Year
        'Intersession', -- Intersession
        'LongSession', -- Long Session
        'MiniTerm', -- Mini Term
        'Quarter', -- Quarter
        'Quinmester', -- Quinmester
        'Semester', -- Semester
        'SummerTerm', -- Summer Term
        'Trimester', -- Trimester
        'TwelveMonth', -- Twelve Month
        'Other' -- Other
    )),
    TimetableDayIdentifier TEXT, -- Rotation cycle identifier, follows XSD:Token format
    CourseSectionMaximumCapacity INTEGER, -- Maximum number of students
    CourseSectionTimeRequiredForCompletion INTEGER, -- Clock minutes for completion
    AbilityGroupingStatus TEXT CHECK (AbilityGroupingStatus IN ('Yes', 'No')),
    AdditionalCreditType TEXT CHECK (AdditionalCreditType IN (
        'AdvancedPlacement', -- Advanced Placement
        'ApprenticeshipCredit', -- Apprenticeship Credit
        'CTE', -- Career and Technical Education
        'DualCredit', -- Dual Credit
        'InternationalBaccalaureate', -- International Baccalaureate
        'Other', -- Other
        'QualifiedAdmission', -- Qualified Admission
        'STEM', -- Science, Technology, Engineering and Mathematics
        'CTEAndAcademic', -- Simultaneous CTE and Academic Credit
        'StateScholarship' -- State Scholarship
    )),
    AdvancedPlacementCourseCode TEXT CHECK (AdvancedPlacementCourseCode IN (
        'ArtHistory', -- Art History
        'Biology', -- Biology
        'CalculusAB', -- Calculus AB
        'CalculusBC', -- Calculus BC
        'Chemistry', -- Chemistry
        'ComputerScienceA', -- Computer Science A
        'ComputerScienceAB', -- Computer Science AB
        'Macroeconomics', -- Macroeconomics
        'Microeconomics', -- Microeconomics
        'EnglishLanguage', -- English Language
        'EnglishLiterature', -- English Literature
        'EnvironmentalScience', -- Environmental Science
        'EuropeanHistory', -- European History
        'FrenchLanguage', -- French Language
        'FrenchLiterature', -- French Literature
        'GermanLanguage', -- German Language
        'CompGovernmentAndPolitics', -- Comp Government And Politics
        'USGovernmentAndPolitics', -- US Government And Politics
        'HumanGeography', -- Human Geography
        'ItalianLanguageAndCulture', -- Italian Language And Culture
        'LatinLiterature', -- Latin Literature
        'LatinVergil', -- Latin Vergil
        'MusicTheory', -- Music Theory
        'PhysicsB', -- Physics B
        'PhysicsC', -- Physics C
        'Psychology', -- Psychology
        'SpanishLanguage', -- Spanish Language
        'SpanishLiterature', -- Spanish Literature
        'Statistics', -- Statistics
        'StudioArt', -- Studio Art
        'USHistory', -- US History
        'WorldHistory' -- World History
    )),
    BlendedLearningModelType TEXT CHECK (BlendedLearningModelType IN (
        'Rotation', -- Rotation model
        'FlexModel', -- Flex model
        'ALaCarte', -- A La Carte model
        'EnrichedVirtual', -- Enriched Virtual model
        'Other' -- Other
    )),
    CareerCluster TEXT CHECK (CareerCluster IN (
        '01', -- Agriculture, Food & Natural Resources
        '02', -- Architecture & Construction
        '03', -- Arts, A/V Technology & Communications
        '04', -- Business Management & Administration
        '05', -- Education & Training
        '06', -- Finance
        '07', -- Government & Public Administration
        '08', -- Health Science
        '09', -- Hospitality & Tourism
        '10', -- Human Services
        '11', -- Information Technology
        '12', -- Law, Public Safety, Corrections & Security
        '13', -- Manufacturing
        '14', -- Marketing
        '15', -- Science, Technology, Engineering & Mathematics
        '16' -- Transportation, Distribution & Logistics
    )),
    ClassroomPositionType TEXT CHECK (ClassroomPositionType IN (
        '03187', -- Administrative staff
        '73071', -- Co-teacher
        '04725', -- Counselor
        '73073', -- Course Proctor
        '05973', -- Instructor of record
        '01234', -- Intern
        '73072', -- Lead Team Teacher
        '00069', -- Non-instructional staff
        '09999', -- Other
        '00059', -- Paraprofessionals/teacher aides
        '05971', -- Primary instructor
        '04735', -- Resource teacher
        '05972', -- Secondary instructor
        '73074', -- Special Education Consultant
        '00080', -- Student teachers
        '01382' -- Volunteer/no contract
    )),
    CourseAlignedWithStandards TEXT CHECK (CourseAlignedWithStandards IN ('Yes', 'No')),
    CourseApplicableEducationLevel TEXT CHECK (CourseApplicableEducationLevel IN (
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'AS', -- Associate's degree
        'BA', -- Bachelor's degree
        'PB', -- Post-baccalaureate certificate
        'MD', -- Master's degree
        'PM', -- Post-master's certificate
        'DO', -- Doctoral degree
        'PD', -- Post-doctoral certificate
        'AE', -- Adult Education
        'PT', -- Professional or technical credential
        'OT' -- Other
    )),
    CourseCertificationDescription TEXT, -- Certification associated with course
    CourseDescription TEXT, -- Description of course content/goals
    CourseFundingProgram TEXT, -- Funding program for course
    CourseFundingProgramAllowed TEXT CHECK (CourseFundingProgramAllowed IN ('Yes', 'No', 'Unknown')),
    CourseGPAApplicability TEXT CHECK (CourseGPAApplicability IN (
        'Applicable', -- Applicable in GPA
        'NotApplicable', -- Not Applicable in GPA
        'Weighted' -- Weighted in GPA
    )),
    CourseInteractionMode TEXT CHECK (CourseInteractionMode IN (
        'Asynchronous', -- Asynchronous
        'Synchronous' -- Synchronous
    )),
    CourseLevelType TEXT CHECK (CourseLevelType IN (
        'Accelerated', -- Accelerated
        'AdultBasic', -- Adult Basic
        'AdvancedPlacement', -- Advanced Placement
        'Basic', -- Basic
        'InternationalBaccalaureate', -- International Baccalaureate
        'CollegeLevel', -- College Level
        'CollegePreparatory', -- College Preparatory
        'GiftedTalented', -- Gifted and Talented
        'Honors', -- Honors
        'NonAcademic', -- Non-Academic
        'SpecialEducation', -- Special Education
        'TechnicalPreparatory', -- Technical Preparatory
        'Vocational', -- Vocational
        'LowerDivision', -- Lower division
        'UpperDivision', -- Upper division
        'Dual', -- Dual level
        'GraduateProfessional', -- Graduate/Professional
        'Regents', -- Regents
        'Remedial', -- Remedial/Developmental
        'K12' -- K12
    )),
    CourseSectionInstructionalDeliveryMode TEXT CHECK (CourseSectionInstructionalDeliveryMode IN (
        'Broadcast', -- Broadcast
        'Correspondence', -- Correspondence
        'EarlyCollege', -- Early College
        'AudioVideo', -- Interactive Audio/Video
        'Online', -- Online
        'IndependentStudy', -- Independent Study
        'FaceToFace', -- Face to Face
        'BlendedLearning' -- Blended Learning
    )),
    CourseSectionSingleSexClassStatus TEXT CHECK (CourseSectionSingleSexClassStatus IN (
        'MaleOnly', -- Male-only
        'FemaleOnly', -- Female-only
        'NotSingleSex' -- Not a single-sex class
    )),
    FamilyAndConsumerSciencesCourseIndicator TEXT CHECK (FamilyAndConsumerSciencesCourseIndicator IN ('Yes', 'No')),
    InstructionLanguage TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    InstructionalMinutes INTEGER, -- Total instructional minutes
    InterdisciplinaryIndicator TEXT CHECK (InterdisciplinaryIndicator IN ('Yes', 'No')),
    NCAAEligibility TEXT CHECK (NCAAEligibility IN ('Yes', 'No')),
    ProjectBasedLearningIndicator TEXT CHECK (ProjectBasedLearningIndicator IN ('Yes', 'No')),
    ProjectBasedLearningType TEXT CHECK (ProjectBasedLearningType IN (
        '1000', -- Primarily Projects
        '1001', -- Student-developed
        '1002', -- Teacher-developed
        '9999' -- Other
    )),
    ReceivingLocationOfInstruction TEXT CHECK (ReceivingLocationOfInstruction IN (
        '00997', -- Business
        '00752', -- Community facility
        '00753', -- Home of student
        '00754', -- Hospital
        '03018', -- Library/media center
        '03506', -- Mobile
        '09999', -- Other
        '00341', -- Other K-12 educational institution
        '00342', -- Postsecondary facility
        '00675' -- School
    )),
    TuitionFunded TEXT CHECK (TuitionFunded IN ('Yes', 'No')),
    VirtualIndicator TEXT CHECK (VirtualIndicator IN ('Yes', 'No')),
    WorkBasedLearningOpportunityType TEXT CHECK (WorkBasedLearningOpportunityType IN (
        'Apprenticeship', -- Apprenticeship
        'ClinicalWork', -- Clinical work experience
        'CooperativeEducation', -- Cooperative education
        'JobShadowing', -- Job shadowing
        'Mentorship', -- Mentorship
        'NonPaidInternship', -- Non-Paid Internship
        'OnTheJob', -- On-the-Job
        'PaidInternship', -- Paid internship
        'ServiceLearning', -- Service learning
        'SupervisedAgricultural', -- Supervised agricultural experience
        'UnpaidInternship', -- Unpaid internship
        'Entrepreneurship', -- Entrepreneurship
        'SchoolBasedEnterprise', -- School-Based Enterprise
        'SimulatedWorksite', -- Simulated Worksite
        'Other' -- Other
    )),
    AvailableCarnegieUnitCredit REAL, -- Carnegie units offered
    CourseCodeSystem TEXT CHECK (CourseCodeSystem IN (
        'Intermediate', -- Intermediate agency course code
        'LEA', -- LEA course code
        'NCES', -- NCES Pilot Standard National Course Classification System
        'Other', -- Other
        'SCED', -- School Codes for the Exchange of Data (SCED) course code
        'School', -- School course code
        'State', -- State course code
        'University' -- University course code
    )),
    CourseDepartmentName TEXT, -- Department with jurisdiction
    CourseLevelApprovalIndicator TEXT CHECK (CourseLevelApprovalIndicator IN ('Yes', 'No')),
    CourseLevelCharacteristic TEXT CHECK (CourseLevelCharacteristic IN (
        '00568', -- Remedial course
        '00569', -- Students with disabilities course
        '00570', -- Basic course
        '00571', -- General course
        '00572', -- Honors level course
        '00573', -- Gifted and talented course
        '00574', -- International Baccalaureate course
        '00575', -- Advanced placement course
        '00576', -- College-level course
        '00577', -- Untracked course
        '00578', -- English Learner course
        '00579', -- Accepted as a high school equivalent
        '73044', -- Career and technical education general course
        '00741', -- Completion of requirement, no units awarded
        '73045', -- Career and technical education dual-credit course
        '73048', -- Dual enrollment
        '73047', -- Not applicable
        '73046', -- Pre-advanced placement
        '73049' -- Other
    )),
    CourseRepeatabilityMaximumNumber INTEGER, -- Max times course can be taken for credit
    CourseSectionAssessmentReportingMethod TEXT CHECK (CourseSectionAssessmentReportingMethod IN (
        '00512', -- Achievement/proficiency level
        '00494', -- ACT score
        '00490', -- Age score
        '00491', -- C-scaled scores
        '00492', -- College Board examination scores
        '00493', -- Grade equivalent or grade-level indicator
        '03473', -- Graduation score
        '03474', -- Growth/value-added/indexing
        '03475', -- International Baccalaureate score
        '00144', -- Letter grade/mark
        '00513', -- Mastery level
        '00497', -- Normal curve equivalent
        '00498', -- Normalized standard score
        '00499', -- Number score
        '00500', -- Pass-fail
        '03476', -- Percentile
        '00502', -- Percentile rank
        '00503', -- Proficiency level
        '03477', -- Promotion score
        '00504', -- Ranking
        '00505', -- Ratio IQ's
        '03478', -- Raw score
        '03479', -- Scale score
        '00506', -- Standard age score
        '00508', -- Stanine score
        '00509', -- Sten score
        '00510', -- T-score
        '03480', -- Workplace readiness score
        '00511', -- Z-score
        '03481', -- SAT Score
        '09999' -- Other
    )),
    CourseTitle TEXT, -- Descriptive name of the course
    CreditUnitType TEXT CHECK (CreditUnitType IN (
        '00585', -- Carnegie unit
        '00586', -- Semester hour credit
        '00587', -- Trimester hour credit
        '00588', -- Quarter hour credit
        '00589', -- Quinmester hour credit
        '00590', -- Mini-term hour credit
        '00591', -- Summer term hour credit
        '00592', -- Intersession hour credit
        '00595', -- Long session hour credit
        '00596', -- Twelve month hour credit
        '00597', -- Career and Technical Education credit
        '73062', -- Adult high school credit
        '00599', -- Credit by examination
        '00600', -- Correspondence credit
        '00601', -- Converted occupational experience credit
        '09999', -- Other
        '75001', -- Certificate credit
        '75002', -- Degree credit
        '75003', -- Continuing education credit
        '75004' -- Professional development hours
    )),
    HighSchoolCourseRequirement TEXT CHECK (HighSchoolCourseRequirement IN ('Yes', 'No')),
    RelatedCompetencyDefinitions TEXT, -- Competency definitions addressed
    SCEDSequenceOfCourse TEXT, -- Sequence as 'n of m' parts
    SequenceOfCourse TEXT -- Sequence as 'n of m' parts
);

-- Creating table for Course Section Attendance entity
CREATE TABLE CourseSectionAttendance (
    CourseSectionIdentifier TEXT NOT NULL, -- References CourseSection table
    StudentIdentifier TEXT NOT NULL, -- References K12Student table
    AttendanceEventDate DATE, -- Date of attendance event
    AttendanceEventType TEXT CHECK (AttendanceEventType IN (
        'DailyAttendance', -- Daily attendance
        'ClassSectionAttendance', -- Class/section attendance
        'ProgramAttendance', -- Program attendance
        'ExtracurricularAttendance' -- Extracurricular attendance
    )),
    AttendanceStatus TEXT CHECK (AttendanceStatus IN (
        'Present', -- Present
        'ExcusedAbsence', -- Excused Absence
        'UnexcusedAbsence', -- Unexcused Absence
        'Tardy', -- Tardy
        'EarlyDeparture' -- Early Departure
    )),
    AttendanceEventDurationDay REAL, -- Duration in days (e.g., 1.0 for whole day)
    AttendanceEventDurationHours REAL, -- Duration in hours
    AttendanceEventDurationMinutes INTEGER -- Duration in minutes
);

-- Creating table for Course Section Enrollment entity
CREATE TABLE CourseSectionEnrollment (
    CourseSectionIdentifier TEXT NOT NULL, -- References CourseSection table
    StudentIdentifier TEXT NOT NULL, -- References K12Student table
    CourseSectionEnrollmentStatusType TEXT CHECK (CourseSectionEnrollmentStatusType IN (
        'Pre-registered', -- Pre-registered
        'Registered', -- Registered
        'Enrolled', -- Enrolled
        'WaitListed', -- Wait Listed
        'Dropped', -- Dropped
        'Completed' -- Completed
    )),
    CourseSectionEnrollmentStatusStartDate DATE, -- Date enrollment status began
    CourseSectionEnrollmentStatusEndDate DATE, -- Date enrollment status ended
    CourseSectionEntryType TEXT CHECK (CourseSectionEntryType IN (
        'NewEnrollment', -- New Enrollment
        'Transfer' -- Transfer
    )),
    CourseSectionExitType TEXT CHECK (CourseSectionExitType IN (
        'Transfer', -- Transferred to another section
        'CompletedForCredit', -- Completed, received credit
        'CompletedNoCredit', -- Completed, no credit
        'Incomplete' -- Did not complete required work
    )),
    CourseSectionExitWithdrawalDate DATE, -- First day after last enrollment
    EnrollmentCapacity INTEGER, -- Maximum age-appropriate students
    EnrollmentEntryDate DATE, -- Date began receiving services
    ExitOrWithdrawalStatus TEXT CHECK (ExitOrWithdrawalStatus IN (
        'Permanent', -- Permanent
        'Temporary' -- Temporary
    )),
    GradeLevelWhenCourseTaken TEXT CHECK (GradeLevelWhenCourseTaken IN (
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    GradeValueQualifier TEXT, -- Scale of grade equivalents
    MarkingPeriodName TEXT, -- Name of marking period
    MidTermMark TEXT, -- Mid-point performance indicator
    NumberOfCreditsAttempted REAL, -- Credits possible for course
    NumberOfCreditsEarned REAL, -- Credits earned for course
    NumberOfDaysAbsent INTEGER, -- Days absent during period
    NumberOfDaysInAttendance INTEGER, -- Days present during period
    NumberOfDaysTardy INTEGER, -- Days tardy during period
    ResponsibleDistrictType TEXT CHECK (ResponsibleDistrictType IN (
        'Accountability', -- Accountability
        'Attendance', -- Attendance
        'Funding', -- Funding
        'Graduation', -- Graduation
        'IndividualizedEducationProgram', -- Individualized education program (IEP)
        'Transportation', -- Transportation
        'IEPServiceProvider', -- IEP service provider
        'Assessment', -- Assessment
        'Instruction', -- Instruction
        'Resident' -- Resident
    )),
    ResponsibleOrganizationType TEXT CHECK (ResponsibleOrganizationType IN (
        'Accountability', -- Accountability
        'Attendance', -- Attendance
        'Funding', -- Funding
        'Graduation', -- Graduation
        'IndividualizedEducationProgram', -- Individualized education program (IEP)
        'Transportation', -- Transportation
        'IEPServiceProvider', -- IEP service provider
        'Assessment', -- Assessment
        'Instruction', -- Instruction
        'Resident' -- Resident
    )),
    ResponsibleSchoolType TEXT CHECK (ResponsibleSchoolType IN (
        'Accountability', -- Accountability
        'Attendance', -- Attendance
        'Funding', -- Funding
        'Graduation', -- Graduation
        'IndividualizedEducationProgram', -- Individualized education program (IEP)
        'Transportation', -- Transportation
        'IEPServiceProvider', -- IEP service provider
        'Assessment', -- Assessment
        'Instruction', -- Instruction
        'Resident' -- Resident
    )),
    StudentCourseSectionGradeEarned TEXT, -- Final grade submitted
    StudentCourseSectionGradeNarrative TEXT, -- Narrative of performance
    StudentCourseSectionMarkFinalIndicator TEXT CHECK (StudentCourseSectionMarkFinalIndicator IN ('Yes', 'No'))
);

-- Creating table for K12 School entity
CREATE TABLE K12School (
    OrganizationIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    OrganizationName TEXT, -- Name of the school
    OrganizationType TEXT CHECK (OrganizationType IN (
        'Employer', -- Employer
        'K12School', -- K12 School
        'LEA', -- Local Education Agency (LEA)
        'IEU', -- Intermediate Educational Unit (IEU)
        'SEA', -- State Education Agency (SEA)
        'Recruiter', -- Recruiter
        'EmployeeBenefitCarrier', -- Employee Benefit Carrier
        'EmployeeBenefitContributor', -- Employee Benefit Contributor
        'ProfessionalMembershipOrganization', -- Professional Membership Organization
        'EducationInstitution', -- Education Institution
        'StaffDevelopmentProvider', -- Staff Development Provider
        'Facility', -- Facility
        'Course', -- Course
        'CourseSection', -- Course Section
        'Program', -- Program
        'PostsecondaryInstitution', -- Postsecondary Institution
        'AdultEducationProvider', -- Adult Education Provider
        'ServiceProvider', -- Service Provider
        'AffiliatedInstitution', -- Affiliated Institution
        'GoverningBoard', -- Governing Board
        'CredentialingOrganization', -- Credentialing Organization
        'AccreditingOrganization', -- Accrediting Organization
        'EducationOrganizationNetwork', -- Education Organization Network
        'IDEAPartCLeadAgency', -- IDEA Part C Lead Agency
        'CharterSchoolManagementOrganization', -- Charter School Management Organization
        'CharterSchoolAuthorizingOrganization', -- Charter School Authorizing Organization
        'EmergencyResponseAgency', -- Emergency Response Agency
        'EarlyCollege', -- Early College
        'Campus', -- Campus
        'PostsecondarySystem', -- Postsecondary System
        'SHEEOAgency', -- SHEEO Agency
        'Region' -- Region
    ))
);

-- Creating table for K12 Staff entity
CREATE TABLE K12Staff (
    StaffIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    StaffIdentificationSystem TEXT CHECK (StaffIdentificationSystem IN (
        'CanadianSIN', -- Canadian Social Insurance Number
        'District', -- District-assigned number
        'Federal', -- Federal identification number
        'School', -- School-assigned number
        'SSN', -- Social Security Administration number
        'State', -- State-assigned number
        'Other' -- Other
    )),
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    OtherFirstName TEXT, -- Alternate first name
    OtherMiddleName TEXT, -- Alternate middle name
    OtherLastName TEXT, -- Alternate last name
    OtherName TEXT, -- Previous or alternate names
    OtherNameType TEXT CHECK (OtherNameType IN (
        'Alias', -- Alias
        'Nickname', -- Nickname
        'OtherName', -- Other name
        'PreviousLegalName', -- Previous legal name
        'PreferredFamilyName', -- Preferred Family Name
        'PreferredGivenName', -- Preferred Given Name
        'FullName' -- Full Name
    ))
);

-- Creating table for K12 Student entity
CREATE TABLE K12Student (
    StudentIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    StudentIdentificationSystem TEXT CHECK (StudentIdentificationSystem IN (
        'CanadianSIN', -- Canadian Social Insurance Number
        'District', -- District-assigned number
        'Family', -- Family unit number
        'Federal', -- Federal identification number
        'NationalMigrant', -- National migrant number
        'School', -- School-assigned number
        'SSN', -- Social Security Administration number
        'State', -- State-assigned number
        'StateMigrant', -- State migrant number
        'BirthCertificate' -- Birth certificate number
    )),
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    OtherFirstName TEXT, -- Alternate first name
    OtherMiddleName TEXT, -- Alternate middle name
    OtherLastName TEXT, -- Alternate last name
    OtherName TEXT, -- Previous or alternate names
    OtherNameType TEXT CHECK (OtherNameType IN (
        'Alias', -- Alias
        'Nickname', -- Nickname
        'OtherName', -- Other name
        'PreviousLegalName', -- Previous legal name
        'PreferredFamilyName', -- Preferred Family Name
        'PreferredGivenName', -- Preferred Given Name
        'FullName' -- Full Name
    ))
);

-- Creating table for LEA entity
CREATE TABLE LEA (
    OrganizationIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    OrganizationName TEXT, -- Name of the LEA
    OrganizationType TEXT CHECK (OrganizationType IN (
        'Employer', -- Employer
        'K12School', -- K12 School
        'LEA', -- Local Education Agency (LEA)
        'IEU', -- Intermediate Educational Unit (IEU)
        'SEA', -- State Education Agency (SEA)
        'Recruiter', -- Recruiter
        'EmployeeBenefitCarrier', -- Employee Benefit Carrier
        'EmployeeBenefitContributor', -- Employee Benefit Contributor
        'ProfessionalMembershipOrganization', -- Professional Membership Organization
        'EducationInstitution', -- Education Institution
        'StaffDevelopmentProvider', -- Staff Development Provider
        'Facility', -- Facility
        'Course', -- Course
        'CourseSection', -- Course Section
        'Program', -- Program
        'PostsecondaryInstitution', -- Postsecondary Institution
        'AdultEducationProvider', -- Adult Education Provider
        'ServiceProvider', -- Service Provider
        'AffiliatedInstitution', -- Affiliated Institution
        'GoverningBoard', -- Governing Board
        'CredentialingOrganization', -- Credentialing Organization
        'AccreditingOrganization', -- Accrediting Organization
        'EducationOrganizationNetwork', -- Education Organization Network
        'IDEAPartCLeadAgency', -- IDEA Part C Lead Agency
        'CharterSchoolManagementOrganization', -- Charter School Management Organization
        'CharterSchoolAuthorizingOrganization', -- Charter School Authorizing Organization
        'EmergencyResponseAgency', -- Emergency Response Agency
        'EarlyCollege', -- Early College
        'Campus', -- Campus
        'PostsecondarySystem', -- Postsecondary System
        'SHEEOAgency', -- SHEEO Agency
        'Region' -- Region
    ))
);

-- Creating table for SEA entity
CREATE TABLE SEA (
    StateAgencyIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    StateAgencyIdentificationSystem TEXT CHECK (StateAgencyIdentificationSystem IN (
        'State', -- State-assigned number
        'Federal', -- Federal identification number
        'FEIN', -- Federal Employer Identification Number
        'NCES', -- National Center for Education Statistics Assigned Number
        'SAM', -- System for Award Management Unique Entity Identifier
        'Other' -- Other
    )),
    OrganizationName TEXT, -- Name of the SEA
    OrganizationType TEXT CHECK (OrganizationType IN (
        'Employer', -- Employer
        'K12School', -- K12 School
        'LEA', -- Local Education Agency (LEA)
        'IEU', -- Intermediate Educational Unit (IEU)
        'SEA', -- State Education Agency (SEA)
        'Recruiter', -- Recruiter
        'EmployeeBenefitCarrier', -- Employee Benefit Carrier
        'EmployeeBenefitContributor', -- Employee Benefit Contributor
        'ProfessionalMembershipOrganization', -- Professional Membership Organization
        'EducationInstitution', -- Education Institution
        'StaffDevelopmentProvider', -- Staff Development Provider
        'Facility', -- Facility
        'Course', -- Course
        'CourseSection', -- Course Section
        'Program', -- Program
        'PostsecondaryInstitution', -- Postsecondary Institution
        'AdultEducationProvider', -- Adult Education Provider
        'ServiceProvider', -- Service Provider
        'AffiliatedInstitution', -- Affiliated Institution
        'GoverningBoard', -- Governing Board
        'CredentialingOrganization', -- Credentialing Organization
        'AccreditingOrganization', -- Accrediting Organization
        'EducationOrganizationNetwork', -- Education Organization Network
        'IDEAPartCLeadAgency', -- IDEA Part C Lead Agency
        'CharterSchoolManagementOrganization', -- Charter School Management Organization
        'CharterSchoolAuthorizingOrganization', -- Charter School Authorizing Organization
        'EmergencyResponseAgency', -- Emergency Response Agency
        'EarlyCollege', -- Early College
        'Campus', -- Campus
        'PostsecondarySystem', -- Postsecondary System
        'SHEEOAgency', -- SHEEO Agency
        'Region' -- Region
    )),
    OrganizationRelationshipType TEXT CHECK (OrganizationRelationshipType IN (
        'AuthorizingBody', -- Authorizing Body
        'OperatingBody', -- Operating Body
        'SecondaryAuthorizingBody', -- Secondary Authorizing Body
        'RelatedBody' -- Related Body
    )),
    OrganizationJurisdictionSquareMiles REAL, -- Total area in square miles
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    OtherFirstName TEXT, -- Alternate first name
    OtherMiddleName TEXT, -- Alternate middle name
    OtherLastName TEXT, -- Alternate last name
    OtherName TEXT, -- Previous or alternate names
    OtherNameType TEXT CHECK (OtherNameType IN (
        'Alias', -- Alias
        'Nickname', -- Nickname
        'OtherName', -- Other name
        'PreviousLegalName', -- Previous legal name
        'PreferredFamilyName', -- Preferred Family Name
        'PreferredGivenName', -- Preferred Given Name
        'FullName' -- Full Name
    )),
    PositionTitle TEXT, -- Descriptive name of position
    PrimaryContactIndicator TEXT CHECK (PrimaryContactIndicator IN ('Yes', 'No')),
    ElectronicMailAddress TEXT, -- Email address
    ElectronicMailAddressType TEXT CHECK (ElectronicMailAddressType IN (
        'Home', -- Home/personal
        'Work', -- Work
        'Organizational', -- Organizational address
        'Other' -- Other
    )),
    TelephoneNumber TEXT, -- Telephone number with area code
    TelephoneNumberType TEXT CHECK (TelephoneNumberType IN (
        'Home', -- Home phone number
        'Work', -- Work phone number
        'Mobile', -- Mobile phone number
        'Fax', -- Fax number
        'Other' -- Other
    )),
    TelephoneNumberListedStatus TEXT CHECK (TelephoneNumberListedStatus IN (
        'Listed', -- Listed
        'Unknown', -- Unknown
        'Unlisted' -- Unlisted
    )),
    PrimaryTelephoneNumberIndicator TEXT CHECK (PrimaryTelephoneNumberIndicator IN ('Yes', 'No')),
    WebSiteAddress TEXT, -- URL of web page
    AddressStreetNumberAndName TEXT, -- Street number and name or PO box
    AddressApartmentRoomOrSuiteNumber TEXT, -- Apartment, room, or suite number
    AddressCity TEXT, -- City name
    AddressCountyName TEXT, -- County name
    AddressPostalCode TEXT, -- Postal code
    AddressTypeForOrganization TEXT CHECK (AddressTypeForOrganization IN (
        'Mailing', -- Mailing
        'Physical', -- Physical
        'Shipping' -- Shipping
    )),
    CountryCode TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    CountyANSICode TEXT, -- ANSI county code, see https://www.census.gov/library/reference/code-lists/ansi.html#par_statelist
    DoNotPublishIndicator TEXT CHECK (DoNotPublishIndicator IN ('Yes', 'No', 'Unknown')),
    Latitude REAL, -- North/south angular distance
    Longitude REAL -- East/west angular distance
);

-- Creating table for SEA Federal Funds entity
CREATE TABLE SEAFederalFunds (
    StateAgencyIdentifier TEXT NOT NULL, -- References SEA table
    DateStateReceivedTitleIIIAllocation DATE, -- Date Title III funds received
    DateTitleIIIFundsAvailableToSubgrantees DATE, -- Date Title III funds available
    NumberOfDaysForTitleIIISubgrants INTEGER, -- Average days to make subgrants
    StateTransferabilityOfFunds TEXT CHECK (StateTransferabilityOfFunds IN ('Yes', 'No')),
    FederalProgramCode TEXT, -- Five-digit federal program code, see https://sam.gov/content/assistance-listings
    FederalProgramsFundingAllocation REAL, -- Amount of federal dollars distributed
    FederalProgramsFundingAllocationType TEXT CHECK (FederalProgramsFundingAllocationType IN (
        'RETAINED', -- Retained by SEA for administration
        'TRANSFER', -- Transferred to another state agency
        'DISTNONLEA', -- Distributed to non-LEA entities
        'UNALLOC' -- Unallocated or returned funds
    ))
);

-- Creating table for SEA Finance entity
CREATE TABLE SEAFinance (
    StateAgencyIdentifier TEXT NOT NULL, -- References SEA table
    FinancialAccountNumber TEXT, -- Account number in local system
    FinancialAccountName TEXT, -- Name of financial account
    FinancialAccountDescription TEXT, -- Description of financial account
    FinancialAccountCategory TEXT CHECK (FinancialAccountCategory IN (
        'Assets', -- Assets
        'Liabilities', -- Liabilities
        'Equity', -- Equity
        'Revenue', -- Revenue and Other Financing Sources
        'Expenditures' -- Expenditures
    )),
    FinancialAccountFundClassification TEXT CHECK (FinancialAccountFundClassification IN (
        '1', -- General Fund
        '2', -- Special Revenue Funds
        '3', -- Capital Projects Funds
        '4', -- Debt Service Funds
        '5', -- Permanent Funds
        '6', -- Enterprise Funds
        '7', -- Internal Service Funds
        '8', -- Trust Funds
        '9' -- Agency Funds
    )),
    FinancialAccountProgramCode TEXT CHECK (FinancialAccountProgramCode IN (
        '100', -- Regular Elementary/Secondary Education Programs
        '200', -- Special Programs
        '300', -- Vocational and Technical Programs
        '400', -- Other Instructional Programs—Elementary/Secondary
        '500', -- Nonpublic School Programs
        '600', -- Adult/Continuing Education Programs
        '700', -- Community/Junior College Education Programs
        '800', -- Community Services Programs
        '900' -- Cocurricular and Extracurricular Activities
    )),
    FinancialAccountProgramName TEXT, -- Name of program area
    FinancialAccountProgramNumber TEXT, -- Number of program area
    FinancialAccountRevenueCode TEXT CHECK (FinancialAccountRevenueCode IN (
        '1000', -- Revenue From Local Sources
        '1100', -- Taxes Levied/Assessed by the School District
        '1110', -- Ad Valorem Taxes
        '1120', -- Sales and Use Taxes
        '1130', -- Income Taxes
        '1140', -- Penalties and Interest on Taxes
        '1190', -- Other Taxes
        '1200', -- Revenue from Local Governmental Units Other Than School Districts
        '1210', -- Ad Valorem Taxes (Received)
        '1220', -- Sales and Use Tax (Received)
        '1230', -- Income Taxes (Received)
        '1240', -- Penalties and Interest on Taxes (Received)
        '1280', -- Revenue in Lieu of Taxes (Received)
        '1290', -- Other Taxes (Received)
        '1300', -- Tuition
        '1310', -- Tuition From Individuals
        '1311', -- Tuition Excluding Summer School
        '1312', -- Tuition for Summer School
        '1320', -- Tuition from Other Government Sources Within State
        '1321', -- Tuition from Other School Districts Within State
        '1322', -- Tuition from Other Government Sources Excluding School Districts
        '1330', -- Tuition from Other Government Sources Outside State
        '1331', -- Tuition from School Districts Outside State
        '1340', -- Tuition from Other Private Sources
        '1350', -- Tuition for Voucher Program Students
        '1400', -- Transportation Fees
        '1410', -- Transportation Fees from Individuals
        '1420', -- Transportation Fees from Other Government Sources Within State
        '1421', -- Transportation Fees from Other School Districts Within State
        '1422', -- Transportation Fees from Other Government Sources Excluding School Districts
        '1430', -- Transportation Fees from Other Government Sources Outside State
        '1431', -- Transportation Fees from School Districts Outside State
        '1440', -- Transportation Fees from Other Private Sources
        '1500', -- Investment Income
        '1510', -- Interest on Investments
        '1520', -- Dividends on Investments
        '1530', -- Net Increase in Fair Value of Investments
        '1531', -- Realized Gains (Losses) on Investments
        '1532', -- Unrealized Gains (Losses) on Investments
        '1540', -- Investment Income from Real Property
        '1600', -- Food Services
        '1610', -- Daily Sales-Reimbursable Programs
        '1611', -- Daily Sales-School Lunch Program
        '1612', -- Daily Sales-School Breakfast Program
        '1613', -- Daily Sales-Special Milk Program
        '1614', -- Daily Sales-After-School Programs
        '1620', -- Daily Sales-Nonreimbursable Programs
        '1630', -- Special Functions
        '1650', -- Daily Sales-Summer Food Programs
        '1700', -- District Activities
        '1710', -- Admissions
        '1720', -- Bookstore Sales
        '1730', -- Student Organization Membership Dues and Fees
        '1740', -- Fees
        '1750', -- Revenue From Enterprise Activities
        '1790', -- Other Activity Income
        '1800', -- Revenue From Community Services Activities
        '1900', -- Other Revenue From Local Sources
        '1910', -- Rentals
        '1920', -- Contributions and Donations From Private Sources
        '1930', -- Gains or Losses on Sale of Capital Assets
        '1940', -- Textbook Sales and Rentals
        '1941', -- Textbook Sales
        '1942', -- Textbook Rentals
        '1950', -- Miscellaneous Revenues From Other School Districts
        '1951', -- Miscellaneous Revenue from Other School Districts Within State
        '1952', -- Miscellaneous Revenue from Other School Districts Outside State
        '1960', -- Miscellaneous Revenues from Other Local Governmental Units
        '1970', -- Revenues From Other Departments in Agency
        '1980', -- Refund of Prior Year's Expenditures
        '1990', -- Miscellaneous Local Revenue
        '2000', -- Revenue From Intermediate Sources
        '2100', -- Unrestricted Grants-in-Aid
        '2200', -- Restricted Grants-in-Aid
        '2800', -- Revenue in Lieu of Taxes
        '2900', -- Revenue for/on Behalf of School District
        '3000', -- Revenue From State Sources
        '3100', -- Unrestricted Grants-in-Aid
        '3200', -- Restricted Grants-in-Aid
        '3700', -- State Grants Through Intermediate Sources
        '3800', -- Revenue in Lieu of Taxes
        '3900', -- Revenue for/on Behalf of School District
        '4000', -- Revenue From Federal Sources
        '4100', -- Unrestricted Grants-in-Aid Direct from Federal Government
        '4200', -- Unrestricted Grants-in-Aid from Federal Government Through State
        '4300', -- Restricted Grants-in-Aid Direct From Federal Government
        '4500', -- Restricted Grants-in-Aid From Federal Government Through State
        '4700', -- Grants-in-Aid From Federal Government Through Other Intermediate Agencies
        '4800', -- Revenue in Lieu of Taxes
        '4900', -- Revenue for/on Behalf of School District
        '5000', -- Other Financing Sources
        '5100', -- Issuance of Bonds
        '5110', -- Bond Principal
        '5120', -- Premium on Issuance of Bonds
        '5200', -- Fund Transfers In
        '5300', -- Proceeds From Disposal of Real or Personal Property
        '5400', -- Loan Proceeds
        '5500', -- Capital Lease Proceeds
        '5600', -- Other Long-Term Debt Proceeds
        '6000', -- Other Revenue Items
        '6100', -- Capital Contributions
        '6200', -- Amortization of Premium on Issuance of Bonds
        '6300', -- Special Items
        '6400' -- Extraordinary Items
    )),
    FinancialAccountingDate DATE, -- Date of financial transaction
    FinancialAccountingPeriodActualValue REAL, -- Actual value for period
    FinancialAccountingPeriodBudgetedValue REAL, -- Budgeted value for period
    FinancialAccountingPeriodEncumberedValue REAL, -- Obligated expense value
    FinancialAccountingValue REAL, -- Point-in-time transaction value
    FinancialExpenditureFunctionCode TEXT CHECK (FinancialExpenditureFunctionCode IN (
        '1000', -- Instruction
        '2000', -- Support Services
        '2100', -- Support Services-Students
        '2110', -- Attendance and Social Work Services
        '2120', -- Guidance Services
        '2130', -- Health Services
        '2140', -- Psychological Services
        '2150', -- Speech Pathology and Audiology Services
        '2160', -- Occupational Therapy-Related Services
        '2170', -- Physical Therapy-Related Services
        '2180', -- Visually Impaired/Vision Services
        '2190', -- Other Support Services-Student
        '2200', -- Support Services-Instruction
        '2210', -- Improvement of Instruction
        '2212', -- Instruction and Curriculum Development
        '2213', -- Instructional Staff Training
        '2219', -- Other Improvement of Instruction Services
        '2220', -- Library/Media Services
        '2230', -- Instruction-Related Technology
        '2240', -- Academic Student Assessment
        '2290', -- Other Support Services-Instructional Staff
        '2300', -- Support Services-General Administration
        '2310', -- Board of Education
        '2320', -- Executive Administration
        '2400', -- Support Services-School Administration
        '2410', -- Office of the Principal
        '2490', -- Other Support Services-School Administration
        '2500', -- Central Services
        '2510', -- Fiscal Services
        '2520', -- Purchasing, Warehousing, and Distributing Services
        '2530', -- Printing, Publishing, and Duplicating Services
        '2540', -- Planning, Research, Development, and Evaluation Services
        '2560', -- Public Information Services
        '2570', -- Personnel Services
        '2580', -- Administrative Technology Services
        '2590', -- Other Support Services-Central Services
        '2600', -- Operation and Maintenance of Plant
        '2610', -- Operation of Buildings
        '2620', -- Maintenance of Buildings
        '2630', -- Care and Upkeep of Grounds
        '2640', -- Care and Upkeep of Equipment
        '2650', -- Vehicle Operation and Maintenance
        '2660', -- Security
        '2670', -- Safety
        '2680', -- Other Operation and Maintenance of Plant
        '2700', -- Student Transportation
        '2710', -- Vehicle Operation
        '2720', -- Monitoring Services
        '2730', -- Vehicle Servicing and Maintenance
        '2790', -- Other Student Transportation Services
        '2900', -- Other Support Services
        '3000', -- Operation of Noninstructional Services
        '3100', -- Food Services Operations
        '3200', -- Enterprise Operations
        '3300', -- Community Services Operations
        '4000', -- Facilities Acquisition and Construction
        '4100', -- Land Acquisition
        '4200', -- Land Improvement
        '4300', -- Architecture and Engineering
        '4400', -- Educational Specifications Development
        '4500', -- Building Acquisition and Construction
        '4600', -- Site Improvements
        '4700', -- Building Improvements
        '4900', -- Other Facilities Acquisition and Construction
        '5000' -- Debt Service
    )),
    FinancialExpenditureLevelofInstructionCode TEXT CHECK (FinancialExpenditureLevelofInstructionCode IN (
        '10', -- Elementary
        '11', -- Prekindergarten
        '12', -- Kindergarten
        '19', -- Other Elementary
        '20', -- Middle
        '30', -- Secondary
        '37', -- Elementary and Secondary Combined
        '40', -- Postsecondary
        '41', -- Programs for Adult/Continuing
        '42', -- Community/Junior College
        '50', -- School Wide
        '60' -- Early Learning Program
    )),
    FinancialExpenditureObjectCode TEXT CHECK (FinancialExpenditureObjectCode IN (
        '100', -- Personal Services-Salaries
        '101', -- Salaries Paid to Teachers
        '102', -- Salaries Paid to Instructional Aides or Assistants
        '103', -- Salaries Paid to Substitute Teachers
        '110', -- Salaries of Regular Employees
        '111', -- Salaries of Regular Employees Paid to Teachers
        '112', -- Salaries of Regular Employees Paid to Instructional Aides
        '113', -- Salaries of Regular Employees Paid to Substitute Teachers
        '120', -- Salaries of Temporary Employees
        '121', -- Salaries of Temporary Employees Paid to Teachers
        '122', -- Salaries of Temporary Employees Paid to Instructional Aides
        '123', -- Salaries of Temporary Employees Paid to Substitute Teachers
        '130', -- Salaries for Overtime
        '131', -- Salaries for Overtime Employees Paid to Teachers
        '132', -- Salaries for Overtime Employees Paid to Instructional Aides
        '133', -- Salaries for Overtime Employees Paid to Substitute Teachers
        '140', -- Salaries for Sabbatical Leave
        '141', -- Salaries for Sabbatical Leave Paid to Teachers
        '142', -- Salaries for Sabbatical Leave Paid to Instructional Aides
        '143', -- Salaries for Sabbatical Leave Paid to Substitute Teachers
        '150', -- Additional Compensation Such as Bonuses or Incentives
        '151', -- Additional Compensation Paid to Teachers
        '152', -- Additional Compensation Paid to Instructional Aides
        '153', -- Additional Compensation Paid to Substitute Teachers
        '200', -- Personal Services-Employee Benefits
        '201', -- Employee Benefits for Teachers
        '202', -- Employee Benefits for Instructional Aides or Assistants
        '203', -- Employee Benefits for Substitute Teachers
        '210', -- Group Insurance
        '211', -- Group Insurance for Teachers
        '212', -- Group Insurance for Instructional Aides or Assistants
        '213', -- Group Insurance for Substitute Teachers
        '220', -- Social Security Contributions
        '221', -- Social Security Payments for Teachers
        '222', -- Social Security Payments for Instructional Aides
        '223', -- Social Security Payments for Substitute Teachers
        '230', -- Retirement Contributions
        '231', -- Retirement Contributions for Teachers
        '232', -- Retirement Contributions for Instructional Aides
        '233', -- Retirement Contributions for Substitute Teachers
        '240', -- On-Behalf Payments
        '241', -- On-Behalf Payments for Teachers
        '242', -- On-Behalf Payments for Instructional Aides
        '243', -- On-Behalf Payments for Substitute Teachers
        '250', -- Tuition Reimbursement
        '251', -- Tuition Reimbursement for Teachers
        '252', -- Tuition Reimbursement for Instructional Aides
        '253', -- Tuition Reimbursement for Substitute Teachers
        '260', -- Unemployment Compensation
        '261', -- Unemployment Compensation Paid for Teachers
        '262', -- Unemployment Compensation Paid for Instructional Aides
        '263', -- Unemployment Compensation Paid for Substitute Teachers
        '270', -- Workers' Compensation
        '271', -- Worker's Compensation Paid for Teachers
        '272', -- Worker's Compensation Paid for Instructional Aides
        '273', -- Worker's Compensation for Substitute Teachers
        '280', -- Health Benefits
        '281', -- Health Benefits Paid for Teachers
        '282', -- Health Benefits Paid for Instructional Aides
        '283', -- Health Benefits Paid for Substitute Teachers
        '290', -- Other Employee Benefits
        '291', -- Other Employee Benefits Paid for Teachers
        '292', -- Other Employee Benefits Paid for Instructional Aides
        '293', -- Other Employee Benefits for Substitute Teachers
        '300', -- Purchased Professional and Technical Services
        '310', -- Official/Administrative Services
        '320', -- Professional Educational Services
        '330', -- Employee Training and Development Services
        '340', -- Other Professional Services
        '350', -- Technical Services
        '351', -- Data-Processing and Coding Services
        '352', -- Other Technical Services
        '400', -- Purchased Property Services
        '410', -- Utility Services
        '420', -- Cleaning Services
        '430', -- Repairs and Maintenance Services
        '431', -- Non-Technology-Related Repairs and Maintenance
        '432', -- Technology-Related Repairs and Maintenance
        '440', -- Rentals
        '441', -- Rentals of Land and Buildings
        '442', -- Rentals of Equipment and Vehicles
        '443', -- Rentals of Computers and Related Equipment
        '450', -- Construction Services
        '490', -- Other Purchased Property Services
        '500', -- Other Purchased Services
        '510', -- Student Transportation Services
        '511', -- Student Transportation Purchased From Another School District Within State
        '512', -- Student Transportation Purchased From Another School District Outside State
        '519', -- Student Transportation Purchased From Other Sources
        '520', -- Insurance (Other Than Employee Benefits)
        '530', -- Communications
        '540', -- Advertising
        '550', -- Printing and Binding
        '560', -- Tuition
        '561', -- Tuition to Other School Districts (Excluding Charter Schools) Within State
        '562', -- Tuition to Other School Districts (Including Charter Schools) Outside State
        '563', -- Tuition to Private Schools
        '564', -- Tuition to Charter Schools Within State
        '565', -- Tuition to Postsecondary Schools
        '566', -- Voucher Payments to Private Schools and Other School Districts Outside State
        '567', -- Voucher Payments to School Districts, including Charter Schools, Within State
        '568', -- Voucher Payments Directly to Individuals
        '569', -- Tuition-Other
        '570', -- Food Service Management
        '580', -- Travel
        '590', -- Interagency Purchased Services
        '591', -- Services Purchased From Another School District or Educational Services Agency Within State
        '592', -- Services Purchased From Another School District or Educational Services Agency Outside State
        '600', -- Supplies
        '610', -- General Supplies
        '620', -- Energy
        '621', -- Natural Gas
        '622', -- Electricity
        '623', -- Bottled Gas
        '624', -- Oil
        '625', -- Coal
        '626', -- Gasoline
        '629', -- Other
        '630', -- Food
        '640', -- Books and Periodicals
        '650', -- Supplies-Technology Related
        '700', -- Property
        '710', -- Land and Land Improvements
        '720', -- Buildings
        '730', -- Equipment
        '731', -- Machinery
        '732', -- Vehicles
        '733', -- Furniture and Fixtures
        '734', -- Technology-Related Hardware
        '735', -- Technology Software
        '739', -- Other Equipment
        '740', -- Infrastructure
        '750', -- Intangible Assets
        '790', -- Depreciation and Amortization
        '800', -- Debt Service and Miscellaneous
        '810', -- Dues and Fees
        '820', -- Judgments Against the School District
        '830', -- Debt-Related Expenditures/Expenses
        '831', -- Redemption of Principal
        '832', -- Interest on Long-Term Debt
        '833', -- Bond Issuance and Other Debt-Related Costs
        '834', -- Amortization of Premium and Discount on Issuance of Bonds
        '835', -- Interest on Short-Term Debt
        '890', -- Miscellaneous Expenditures
        '900', -- Other Items
        '910', -- Fund Transfers Out
        '920', -- Payments to Escrow Agents for Defeasance of Debt
        '925', -- Discount on the Issuance of Bonds
        '930', -- Net Decreases in the Fair Value of Investments
        '931', -- Realized Losses on Investments
        '932', -- Unrealized Losses on Investments
        '940', -- Losses on the Sale of Capital Assets
        '950', -- Special Items
        '960' -- Extraordinary Items
    )),
    FinancialExpenditureProjectReportingCode TEXT, -- Three-digit project/reporting code
    FiscalPeriodBeginDate DATE, -- Date accounting period begins
    FiscalPeriodEndDate DATE, -- Date accounting period ends
    FiscalYear INTEGER, -- Year for budgeting/accounting
    FundingSourceAmount REAL, -- Amount from specific funding source
    FundingSourcePercentage REAL -- Proportion of total funding
);

-- Creating table for SEA Job entity
CREATE TABLE SEAJob (
    StateAgencyIdentifier TEXT NOT NULL, -- References SEA table
    JobIdentifier TEXT NOT NULL, -- Unique job identifier, follows XSD:Token format
    JobIdentificationSystem TEXT CHECK (JobIdentificationSystem IN (
        'LEA', -- Local Education Agency assigned number
        'School', -- School-assigned number
        'SEA', -- State Education Agency assigned number
        'Other' -- Other
    )),
    JobPositionIdentifier TEXT, -- Unique job position identifier, follows XSD:Token format
    JobPositionIdentificationSystem TEXT CHECK (JobPositionIdentificationSystem IN (
        'LEA', -- Local Education Agency assigned number
        'School', -- School-assigned number
        'SEA', -- State Education Agency assigned number
        'Other' -- Other
    )),
    JobPositionStatus TEXT CHECK (JobPositionStatus IN (
        'Active', -- Active
        'Approved', -- Approved
        'Cancelled', -- Cancelled
        'Filled', -- Filled
        'Frozen' -- Frozen
    )),
    JobPositionStatusDate DATE, -- Effective date of job position status
    JobPositionStatusCancelledReason TEXT CHECK (JobPositionStatusCancelledReason IN (
        '1001', -- Budgetary Reduction
        '1003', -- Enrollment Changes
        '1002', -- Organizational Restructure
        '1004', -- Specific Grant or Funding Expiration
        '9999' -- Other
    )),
    JobPositionExpectedStartDate DATE, -- Anticipated start date
    EducationJobType TEXT CHECK (EducationJobType IN (
        '1000', -- Instructional
        '1002', -- Non-Instructional Support and Services
        '1001', -- Student Support Staff
        '9999' -- Other
    )),
    CodingSystemOrganizationType TEXT CHECK (CodingSystemOrganizationType IN (
        'LEA', -- Local Education Agency
        'SEA', -- State Education Agency
        'Other' -- Other
    )),
    LocalJobCategory TEXT CHECK (LocalJobCategory IN ('Other')), -- Local job classification
    LocalJobFunction TEXT CHECK (LocalJobFunction IN ('Other')) -- Local job function
);

-- Creating table for Facility entity
CREATE TABLE Facility (
    FacilitiesIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    OrganizationIdentifier TEXT, -- Unique organization identifier, follows XSD:Token format
    OrganizationIdentificationSystem TEXT CHECK (OrganizationIdentificationSystem IN (
        'School', -- School-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'LEA', -- Local Education Agency assigned number
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'FEIN', -- Federal employer identification number
        'DUNS', -- Dun and Bradstreet number
        'OtherFederal', -- Other federally assigned number
        'Other', -- Other
        'LicenseNumber', -- License Number
        'SAM' -- System for Award Management Unique Entity Identifier
    )),
    OrganizationName TEXT, -- Full legal or popular name of the organization
    ShortNameOfOrganization TEXT, -- Abbreviated name of the organization
    OrganizationType TEXT CHECK (OrganizationType IN (
        'Employer', -- Employer
        'K12School', -- K12 School
        'LEA', -- Local Education Agency (LEA)
        'IEU', -- Intermediate Educational Unit (IEU)
        'SEA', -- State Education Agency (SEA)
        'Recruiter', -- Recruiter
        'EmployeeBenefitCarrier', -- Employee Benefit Carrier
        'EmployeeBenefitContributor', -- Employee Benefit Contributor
        'ProfessionalMembershipOrganization', -- Professional Membership Organization
        'EducationInstitution', -- Education Institution
        'StaffDevelopmentProvider', -- Staff Development Provider
        'Facility', -- Facility
        'Course', -- Course
        'CourseSection', -- Course Section
        'Program', -- Program
        'PostsecondaryInstitution', -- Postsecondary Institution
        'AdultEducationProvider', -- Adult Education Provider
        'ServiceProvider', -- Service Provider
        'AffiliatedInstitution', -- Affiliated Institution
        'GoverningBoard', -- Governing Board
        'CredentialingOrganization', -- Credentialing Organization
        'AccreditingOrganization', -- Accrediting Organization
        'EducationOrganizationNetwork', -- Education Organization Network
        'IDEAPartCLeadAgency', -- IDEA Part C Lead Agency
        'CharterSchoolManagementOrganization', -- Charter School Management Organization
        'CharterSchoolAuthorizingOrganization', -- Charter School Authorizing Organization
        'EmergencyResponseAgency', -- Emergency Response Agency
        'EarlyCollege', -- Early College
        'Campus', -- Campus
        'PostsecondarySystem', -- Postsecondary System
        'SHEEOAgency', -- SHEEO Agency
        'Region' -- Region
    )),
    OrganizationRelationshipType TEXT CHECK (OrganizationRelationshipType IN (
        'AuthorizingBody', -- Authorizing Body
        'OperatingBody', -- Operating Body
        'SecondaryAuthorizingBody', -- Secondary Authorizing Body
        'RelatedBody' -- Related Body
    )),
    OrganizationRegionGeoJSON TEXT, -- Geo-political area in GeoJSON format
    FacilityBuildingName TEXT, -- Full legal or popular name of the building
    FacilityBuildingPermanency TEXT CHECK (FacilityBuildingPermanency IN (
        '02432', -- Nonpermanent building
        '02431' -- Permanent building
    )),
    BuildingArea REAL, -- Sum of areas at each floor level
    TemperatureControlledBuildingArea REAL, -- Area with regulated temperature
    BuildingNumberOfStories INTEGER, -- Number of stories excluding basement
    BuildingPrimaryUseType TEXT CHECK (BuildingPrimaryUseType IN (
        '13561', -- Church
        '13562', -- Commercial office building
        '13563', -- Commercial warehouse
        '13564', -- Community center
        '13565' -- Public school building
    )),
    BuildingYearBuilt INTEGER, -- Year building was constructed
    BuildingYearOfLastModernization INTEGER, -- Year of comprehensive upgrade
    CampusType TEXT CHECK (CampusType IN (
        'Administration', -- Administration
        'Education', -- Education
        'Operations', -- Operations
        'Residential', -- Residential
        'Other' -- Other
    )),
    CampusStatus TEXT CHECK (CampusStatus IN (
        '75021', -- In district use
        '75022', -- Leased
        '75023', -- Inactive
        '75024', -- Decommissioned
        '75025' -- Sold
    )),
    FacilityAcquisitionDate DATE, -- Date property was acquired
    FacilityAdditionYear INTEGER, -- Year addition construction completed
    FacilityBlockNumberArea TEXT, -- Informal rural location description
    FacilityCensusTract TEXT, -- Census tract number
    FacilityConstructionDate DATE, -- Date construction completed
    FacilityConstructionDateType TEXT CHECK (FacilityConstructionDateType IN (
        '02420', -- Actual
        '02421' -- Estimated
    )),
    FacilityConstructionMaterialType TEXT CHECK (FacilityConstructionMaterialType IN (
        '02430', -- Adobe
        '02428', -- Aluminum
        '02424', -- Block
        '02422', -- Brick
        '02423', -- Brick veneer
        '02426', -- Concrete
        '02427', -- Prefabricated
        '02429', -- Steel
        '02425', -- Wood frame
        '09999' -- Other
    )),
    FacilityConstructionYear INTEGER, -- Year building first constructed
    FacilityExpectedLife INTEGER, -- Expected useful life in years
    FacilityOwnershipIndicator TEXT CHECK (FacilityOwnershipIndicator IN ('Yes', 'No')),
    FacilityReplacementValue REAL, -- Estimated replacement cost
    FacilitySiteArea REAL, -- Total acres of land
    FacilitySiteIdentifier TEXT, -- Lot and square number
    BuildingHistoricStatus TEXT CHECK (BuildingHistoricStatus IN (
        '02415', -- Ineligible
        '02417', -- Locally designated
        '02412', -- Locally eligible, not yet designated
        '75020', -- Located in historic district
        '02419', -- Nationally designated
        '02414', -- Nationally eligible, not yet designated
        '02416', -- Not evaluated
        '02418', -- State designated
        '02413' -- State eligible, not yet designated
    ))
);

-- Creating table for Facility Address entity
CREATE TABLE FacilityAddress (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    AddressStreetNumberAndName TEXT, -- Street number and name or PO box
    AddressApartmentRoomOrSuiteNumber TEXT, -- Apartment, room, or suite number
    AddressCity TEXT, -- City name
    AddressCountyName TEXT, -- County name
    AddressPostalCode TEXT, -- Postal code
    AddressTypeForOrganization TEXT CHECK (AddressTypeForOrganization IN (
        'Mailing', -- Mailing
        'Physical', -- Physical
        'Shipping' -- Shipping
    )),
    BuildingSiteNumber TEXT, -- Building number on site
    CountyANSICode TEXT, -- ANSI county code, see https://www.census.gov/library/reference/code-lists/ansi.html#par_statelist
    DoNotPublishIndicator TEXT CHECK (DoNotPublishIndicator IN ('Yes', 'No', 'Unknown')),
    Latitude REAL, -- North/south angular distance
    Longitude REAL, -- East/west angular distance
    StateAbbreviation TEXT CHECK (StateAbbreviation IN (
        'AK', -- Alaska
        'AL', -- Alabama
        'AR', -- Arkansas
        'AS', -- American Samoa
        'AZ', -- Arizona
        'CA', -- California
        'CO', -- Colorado
        'CT', -- Connecticut
        'DC', -- District of Columbia
        'DE', -- Delaware
        'FL', -- Florida
        'FM', -- Federated States of Micronesia
        'GA', -- Georgia
        'GU', -- Guam
        'HI', -- Hawaii
        'IA', -- Iowa
        'ID', -- Idaho
        'IL', -- Illinois
        'IN', -- Indiana
        'KS', -- Kansas
        'KY', -- Kentucky
        'LA', -- Louisiana
        'MA', -- Massachusetts
        'MD', -- Maryland
        'ME', -- Maine
        'MH', -- Marshall Islands
        'MI', -- Michigan
        'MN', -- Minnesota
        'MO', -- Missouri
        'MP', -- Northern Marianas
        'MS', -- Mississippi
        'MT', -- Montana
        'NC', -- North Carolina
        'ND', -- North Dakota
        'NE', -- Nebraska
        'NH', -- New Hampshire
        'NJ', -- New Jersey
        'NM', -- New Mexico
        'NV', -- Nevada
        'NY', -- New York
        'OH', -- Ohio
        'OK', -- Oklahoma
        'OR', -- Oregon
        'PA', -- Pennsylvania
        'PR', -- Puerto Rico
        'PW', -- Palau
        'RI', -- Rhode Island
        'SC', -- South Carolina
        'SD', -- South Dakota
        'TN', -- Tennessee
        'TX', -- Texas
        'UT', -- Utah
        'VA', -- Virginia
        'VI', -- Virgin Islands
        'VT', -- Vermont
        'WA', -- Washington
        'WI', -- Wisconsin
        'WV', -- West Virginia
        'WY', -- Wyoming
        'AA', -- Armed Forces America
        'AE', -- Armed Forces Africa, Canada, Europe, and Mideast
        'AP', -- Armed Forces Pacific
        'BI', -- Bureau of Indian Affairs
        'DD', -- Department of Defense Domestic
        'DO' -- Department of Defense Overseas
    ))
);

-- Creating table for Facility Budget and Finance entity
CREATE TABLE FacilityBudgetFinance (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    FacilityFinancingFeeType TEXT CHECK (FacilityFinancingFeeType IN (
        '13717', -- Application fee
        '13718', -- Legal fee
        '13719' -- Origination fee
    )),
    FacilityLeaseAmount REAL, -- Amount paid to rent facility
    FacilityLeaseAmountCategory TEXT CHECK (FacilityLeaseAmountCategory IN (
        '13720', -- Base rent
        '13721', -- Credit
        '13722' -- Escalator
    )),
    FacilityLeaseType TEXT CHECK (FacilityLeaseType IN (
        '13723', -- Building lease
        '13724', -- Ground lease
        '13725', -- Lease build to suit
        '13726', -- Lease shell with significant leasehold improvements
        '13727' -- Triple-net lease
    )),
    FacilityMortgageInterestAmount REAL, -- Interest paid on mortgage
    FacilityMortgageInterestType TEXT CHECK (FacilityMortgageInterestType IN (
        '13730', -- Add-on interest
        '13731', -- Adjustable-Rate Mortgage (ARM)
        '13732', -- Balloon Mortgage
        '13733', -- Deferred Interest
        '13734', -- Fixed Payment Mortgage
        '13735', -- Fixed-rate Mortgage
        '13736', -- Floating Rate
        '13737', -- Fully Amortizing Mortgage
        '13738', -- Graduated-payment Mortgage (GPM)
        '13739', -- Interest-only loan
        '13740' -- Open-end Mortgage
    )),
    FacilityMortgageType TEXT CHECK (FacilityMortgageType IN (
        '13741', -- Junior Mortgage
        '13742', -- Multiple
        '13743' -- Senior or first mortgage
    )),
    FacilityTotalAssessedValue REAL -- Total assessed value for borrowing
);

-- Creating table for Facility Condition entity
CREATE TABLE FacilityCondition (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    BuildingAirDistributionSystemType TEXT CHECK (BuildingAirDistributionSystemType IN (
        '02497', -- Air handler units
        '02496', -- Both mechanical exhaust and supply units
        '02493', -- Gravity ventilation units
        '02494', -- Mechanical exhaust units
        '02495', -- Mechanical supply units
        '09999', -- Other units
        '02492' -- Window ventilation units
    )),
    BuildingCommunicationsManagementComponentSystemType TEXT CHECK (BuildingCommunicationsManagementComponentSystemType IN (
        '02500', -- Data
        '14905', -- Integrated (voice, data, video, etc.)
        '02501', -- Public address system
        '02499', -- Video
        '02498', -- Voice
        '09999' -- Other
    )),
    BuildingCoolingGenerationSystemType TEXT CHECK (BuildingCoolingGenerationSystemType IN (
        '02490', -- Ceiling fans or ventilation fans
        '02486', -- Central cooling system
        '02489', -- Combination cooling systems
        '02488', -- Individual (room) unit cooling system
        '02487', -- Local zone cooling system
        '02491', -- Natural systems
        '09998', -- None
        '09999' -- Other
    )),
    BuildingElectricalSystemType TEXT CHECK (BuildingElectricalSystemType IN (
        '02476', -- Circuit breakers
        '13570', -- Communications and security
        '02473', -- Electrical distribution
        '02475', -- Electrical interface
        '13571', -- Electrical service and distribution
        '02472', -- Electrical supply
        '02474', -- Emergency generator
        '13572', -- Lighting and branch wiring
        '09999' -- Other
    )),
    BuildingFireProtectionSystemType TEXT CHECK (BuildingFireProtectionSystemType IN (
        '02513', -- Alarms
        '02511', -- Automatic sprinkler
        '13579', -- Fire protection specialists
        '02512', -- Fire pump/extinguishers
        '02514', -- Kitchen fire suppressor system
        '13580', -- Other fire protection systems
        '13581', -- Standpipes
        '09999' -- Other
    )),
    BuildingHeatingGenerationSystemType TEXT CHECK (BuildingHeatingGenerationSystemType IN (
        '02482', -- Central duct system
        '02485', -- Displacement ventilation
        '02484', -- Forced air
        '02479', -- Heat pump
        '02478', -- Hot water radiator
        '02483', -- Open plenum system
        '02477', -- Steam radiator
        '02481', -- Unit heaters/baseboard heaters
        '02480', -- Unit ventilators
        '09999' -- Other
    )),
    BuildingHVACSystemType TEXT CHECK (BuildingHVACSystemType IN (
        '13585', -- Air distribution system
        '13586', -- Controls and instrumentation
        '13587', -- Cooling generation systems
        '13588', -- Energy supply
        '13589', -- Heat generating system
        '13590', -- Other HVAC systems and equipment
        '13591', -- Systems testing and balancing
        '13592' -- Terminal and package units
    )),
    BuildingInstitutionalEquipmentDescription TEXT, -- Equipment for instructional support
    BuildingMechanicalConveyingSystemType TEXT CHECK (BuildingMechanicalConveyingSystemType IN (
        '02516', -- Elevator
        '02517', -- Escalator
        '13593', -- Lift
        '13594', -- Moving Walk
        '13595' -- Other conveying system
    )),
    BuildingMechanicalSystemType TEXT CHECK (BuildingMechanicalSystemType IN (
        '02455', -- Air distribution system
        '02454', -- Cooling generation system
        '02453', -- Heating generation system
        '09999' -- Other
    )),
    BuildingPlumbingSystemType TEXT CHECK (BuildingPlumbingSystemType IN (
        '02470', -- Detention ponds
        '13596', -- Domestic water distribution
        '02463', -- Drains
        '02471', -- Filtration system
        '02467', -- Parcel drainage
        '02468', -- Piping
        '13597', -- Plumbing fixtures
        '13598', -- Rain water drainage
        '13599', -- Sanitary waste
        '02465', -- Sewage treatment
        '02464', -- Vents
        '02469', -- Water softeners
        '02466', -- Water source
        '02462', -- Water supply
        '09999' -- Other
    )),
    BuildingSecuritySystemType TEXT CHECK (BuildingSecuritySystemType IN (
        '02508', -- Card access control system
        '02507', -- Intrusion detection system
        '02509', -- Keypad access control system
        '02510', -- Metal detector
        '02499', -- Video
        '09999' -- Other
    )),
    BuildingSystemType TEXT CHECK (BuildingSystemType IN (
        '02455', -- Air distribution system
        '02456', -- Communications system
        '02454', -- Cooling generation system
        '02452', -- Electrical system
        '02459', -- Fire protection system
        '02453', -- Heating generation system
        '02460', -- Mechanical system
        '02451', -- Plumbing system
        '02458', -- Security system
        '02457', -- Technology wiring
        '02461' -- Vertical transportation
    )),
    BuildingTechnologyWiringSystemType TEXT CHECK (BuildingTechnologyWiringSystemType IN (
        '02504', -- Coaxial cable
        '02503', -- Fiber optic cable
        '02506', -- Twisted pair
        '02502', -- Wire cable
        '02505', -- Wireless
        '09999' -- Other
    )),
    BuildingVerticalTransportationSystemType TEXT CHECK (BuildingVerticalTransportationSystemType IN (
        '02516', -- Elevator
        '02517', -- Escalator
        '02515', -- Stairs
        '09999' -- Other
    )),
    ComponentOrFixtureCheckDate DATE, -- Date condition checked
    ComponentOrFixtureScheduledServicedDate DATE, -- Date scheduled for service
    ComponentOrFixtureServicedDate DATE, -- Date serviced
    ComponentOrFixtureUsefulLife INTEGER, -- Expected operational life in years
    FacilityApplicableFederalMandateType TEXT CHECK (FacilityApplicableFederalMandateType IN (
        '02584', -- Americans with Disabilities Act (ADA)
        '02588', -- Asbestos Hazardous Emergency Response Act (AHERA)
        '02585', -- Individuals with Disabilities Education Act (IDEA)
        '02587', -- Lead Contamination Control Act
        '02586', -- Safe Drinking Water Act
        '09999' -- Other
    )),
    FacilityComplianceStatus TEXT CHECK (FacilityComplianceStatus IN (
        '02570', -- In compliance
        '02571', -- Not in compliance
        '02572', -- Planned compliance
        '02573' -- Waived compliance
    )),
    FacilityFederalMandateInterestType TEXT CHECK (FacilityFederalMandateInterestType IN (
        '02579', -- Asbestos contamination
        '75026', -- Child nutrition
        '02577', -- Drinking water safety
        '02574', -- Facility accessibility for disabilities
        '02580', -- Hazardous materials
        '02575', -- Indoor air quality
        '02583', -- Integrated pest control
        '02578', -- Lead contamination
        '02582', -- Material Safety Data Sheet (MSDS)
        '03264', -- National School Lunch Act
        '02576', -- Radon contamination
        '02581', -- Underground storage tank
        '09999' -- Other
    )),
    FacilityLocationOfHazardousMaterials TEXT, -- Location of hazardous materials
    FacilityNearbyEnvironmentalHazardDescription TEXT, -- Nearby environmental hazards
    FacilityStateOrLocalMandateInterestType TEXT CHECK (FacilityStateOrLocalMandateInterestType IN (
        '02594', -- Acreage standards
        '02589', -- Building code
        '02593', -- Design standards
        '02598', -- Earthquake standards
        '02590', -- Fire code
        '02592', -- Flood control
        '03265', -- Food safety standards
        '02591', -- Health code
        '02596', -- Historic preservation requirements
        '02597', -- Occupational health and safety code
        '02595', -- Standard educational specifications
        '09999' -- Other
    )),
    FacilityStateOrLocalMandateName TEXT, -- Name of state or local mandate
    FacilitySystemOrComponentCondition TEXT CHECK (FacilitySystemOrComponentCondition IN (
        '02563', -- Adequate system or component condition
        '02567', -- Emergency system or component condition
        '02561', -- Excellent System or Component Condition
        '02564', -- Fair System or Component Condition
        '02562', -- Good System or Component Condition
        '02983', -- Nonoperable system or component condition
        '02565', -- Poor System or Component Condition
        '02566' -- Urgent building system or component condition
    ))
);

-- Creating table for Facility Design entity
CREATE TABLE FacilityDesign (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    BuildingAdministrativeSpaceType TEXT CHECK (BuildingAdministrativeSpaceType IN (
        '02986', -- Administrative office/room
        '02747', -- Attendance reception
        '02744', -- Clerical areas
        '02746', -- Conference room
        '02748', -- General reception
        '75032', -- IT center
        '02745', -- Mail room
        '02742', -- Principal's office
        '02754', -- PTO/PTA spaces
        '02756', -- Records room/vault
        '02753', -- School bank
        '02752', -- School store
        '02749', -- Security/police/probation office
        '02755', -- Site-based council office
        '02750', -- Staff lounge
        '02751', -- Staff work room
        '02759', -- Storage - instructional equipment
        '02758', -- Storage - resource materials
        '02757', -- Storage - textbook
        '02743', -- Vice-principal/assistant principal's office
        '09999' -- Other
    )),
    BuildingArchitectName TEXT, -- Name of architect
    BuildingArchitecturalFirmName TEXT, -- Name of architectural firm
    BuildingArtSpecialtySpaceType TEXT CHECK (BuildingArtSpecialtySpaceType IN (
        '02644', -- 2-dimensional art classroom
        '02645', -- 3-dimensional art classroom
        '02647', -- Ceramic studio
        '02646', -- Darkroom
        '02649', -- Kiln room
        '02648', -- Photography studio/graphic arts
        '09999' -- Other
    )),
    BuildingAssemblySpaceType TEXT CHECK (BuildingAssemblySpaceType IN (
        '02768', -- Auditorium (fixed seats)
        '02772', -- Backstage room/green room
        '02769', -- Control room
        '02770', -- Costume storage area
        '03108', -- Disaster shelter area
        '02773', -- Multi-purpose Room
        '02771', -- Set storage area
        '09999' -- Other
    )),
    BuildingBasicClassroomDesignType TEXT CHECK (BuildingBasicClassroomDesignType IN (
        '01304', -- Elementary
        '01981', -- Preschool/early childhood
        '03495', -- Resource
        '02403', -- Secondary
        '14906', -- Skills center
        '09999' -- Other
    )),
    BuildingCareerTechnicalEducationSpaceType TEXT CHECK (BuildingCareerTechnicalEducationSpaceType IN (
        '02691', -- Aeronautical technology classroom
        '02685', -- Agricultural/natural resources shop
        '02682', -- Automotive/avionics technology shop
        '02687', -- Barbering and cosmetology shop
        '02702', -- Biotechnology laboratory
        '02692', -- Building construction technology shop
        '02697', -- Business and administrative services/office management laboratory
        '02678', -- Computer/information technology laboratory
        '02680', -- Consumer science - clothing classroom
        '02679', -- Consumer science - food classroom
        '02690', -- Dental science classroom
        '02684', -- Drafting room/CAD/CAM
        '02699', -- Early childhood laboratory/child care center
        '02683', -- Electronics/engineering technology laboratory
        '02681', -- Family and consumer science
        '02695', -- Financial services center/bank
        '02696', -- Food services/hospitality laboratory
        '02700', -- Graphic/digital arts and design studio
        '02686', -- Greenhouse
        '02698', -- Health occupations laboratory
        '02701', -- Law enforcement/fire technology/protective services laboratory
        '02688', -- Multimedia production studio/communications
        '02693', -- Precision manufacturing laboratory/metalworking shop
        '02694', -- Retail store/entrepreneurship laboratory
        '02689', -- Wood shop
        '09999' -- Other
    )),
    BuildingCirculationSpaceType TEXT CHECK (BuildingCirculationSpaceType IN (
        '02516', -- Elevator
        '02517', -- Escalator
        '02774', -- Hallway
        '13619', -- Handicap Access Ramp
        '13593', -- Lift
        '02776', -- Lobby
        '13594', -- Moving Walk
        '02775', -- Stairway
        '09999' -- Other
    )),
    BuildingDesignType TEXT CHECK (BuildingDesignType IN (
        '02621', -- Assembly building
        '02614', -- Central kitchen building
        '02619', -- Dormitory building
        '02616', -- Field house building
        '02613', -- Garage building
        '02620', -- Gymnasium building
        '02617', -- Media production center building
        '02618', -- Natatorium
        '02611', -- Office building
        '03106', -- School building
        '02610', -- Service center building
        '02615', -- Stadium building
        '02612', -- Warehouse building
        '09999' -- Other
    )),
    BuildingEnvironmentalOrEnergyPerformanceRatingCategory TEXT CHECK (BuildingEnvironmentalOrEnergyPerformanceRatingCategory IN (
        '13620', -- Climate/Emissions
        '13621', -- Energy
        '13622', -- Indoor Environmental Quality
        '13623', -- Innovations in Operations/Project/Environmental Management
        '13624', -- Leadership, Education and Innovation
        '13625', -- Materials and Resources
        '13626', -- Regional Priority
        '13627' -- Sustainable Sites
    )),
    BuildingFoodServiceSpaceType TEXT CHECK (BuildingFoodServiceSpaceType IN (
        '02792', -- Cafeteria
        '02793', -- Cafetorium
        '02797', -- Convenience kitchen
        '03251', -- Dish return area
        '02799', -- Dry food/non-hazardous supplies storage area
        '02794', -- Faculty dining room
        '02798', -- Finishing/satellite kitchen
        '03254', -- Food receiving area
        '02800', -- Food serving area
        '02796', -- Full-service kitchen
        '13629', -- Kitchen garden
        '02988', -- Multipurpose room
        '03253', -- Recyclable materials area
        '03109', -- Refrigerated/freezer storage area
        '02801', -- Storage of tables and chairs
        '02795', -- Student dining room
        '03252', -- Trash disposal area
        '09999' -- Other
    )),
    BuildingFullServiceKitchenType TEXT CHECK (BuildingFullServiceKitchenType IN (
        '03247', -- Central kitchen
        '03250', -- Non-production kitchen
        '03248', -- Production kitchen
        '03249' -- Self-contained kitchen
    )),
    BuildingIndoorAthleticOrPhysicalEducationSpaceType TEXT CHECK (BuildingIndoorAthleticOrPhysicalEducationSpaceType IN (
        '02709', -- Auxiliary gymnasium
        '02712', -- Dance studio
        '02716', -- Equipment storage
        '02984', -- Gymnasium
        '02719', -- Health classroom
        '02715', -- Locker room
        '02718', -- Multipurpose space
        '02720', -- Playtorium (auditorium/gymnasium)
        '02714', -- Pool/natatorium
        '02717', -- Press box
        '02713', -- Team room
        '02710', -- Weight training room
        '02711', -- Wrestling room
        '09999' -- Other
    )),
    BuildingLibraryOrMediaCenterSpecialtySpaceType TEXT CHECK (BuildingLibraryOrMediaCenterSpecialtySpaceType IN (
        '02703', -- Collections room
        '02706', -- Copy center
        '02705', -- Distance learning lab
        '02704', -- Reading room
        '13632', -- Reception/checkout desk
        '02707', -- Study room
        '02708', -- Workroom
        '09999' -- Other
    )),
    BuildingOperationsOrMaintenanceSpaceType TEXT CHECK (BuildingOperationsOrMaintenanceSpaceType IN (
        '02780', -- Boiler room
        '02784', -- Communications closet
        '02778', -- Custodial closet
        '02777', -- Custodian office
        '02783', -- Electrical closet
        '02781', -- Fan room
        '02779', -- Mechanical room
        '02790', -- Public toilet
        '02785', -- Server room
        '02791', -- Staff toilet
        '02786', -- Storage - flammable materials
        '02788', -- Storage - hazardous materials
        '02787', -- Storage - maintenance equipment
        '02789', -- Student toilet
        '02782', -- Systems control room
        '09999' -- Other
    )),
    BuildingOutdoorAthleticOrPhysicalEducationSpaceType TEXT CHECK (BuildingOutdoorAthleticOrPhysicalEducationSpaceType IN (
        '02728', -- Baseball field
        '02724', -- Bleacher seating
        '02722', -- Concessions/restrooms
        '02985', -- Field house
        '02727', -- Fitness trail
        '02730', -- Football field
        '02721', -- Multipurpose grassy play field
        '02732', -- Other sports field
        '02726', -- Paved outdoor basketball courts
        '02731', -- Soccer field
        '02729', -- Softball field
        '02725', -- Tennis courts
        '02723', -- Track/fields
        '09999' -- Other
    )),
    BuildingOutdoorOrNonAthleticSpaceType TEXT CHECK (BuildingOutdoorOrNonAthleticSpaceType IN (
        '13629', -- Kitchen garden
        '13635', -- Natural habitat area
        '13633', -- Outdoor classroom
        '13634', -- Outdoor seating
        '02433', -- Playground
        '03409', -- Sandbox
        '03407', -- Schoolyard Garden
        '13636' -- Splash play area
    )),
    BuildingPerformingArtsSpecialtySpaceType TEXT CHECK (BuildingPerformingArtsSpecialtySpaceType IN (
        '02768', -- Auditorium (fixed seats)
        '02772', -- Backstage room/green room
        '13637', -- Balcony
        '02650', -- Band room
        '02654', -- Blackbox theater
        '02652', -- Choral room
        '02769', -- Control room
        '02770', -- Costume storage area
        '02653', -- Drama classroom
        '02655', -- Instrument storage
        '02656', -- Keyboard laboratory
        '02659', -- Multimedia production center
        '02658', -- Multipurpose music room
        '02651', -- Practice room
        '02660', -- Radio/television broadcast studios
        '02771', -- Set storage area
        '02657', -- Television studio
        '09999' -- Other
    )),
    BuildingSchoolDesignType TEXT CHECK (BuildingSchoolDesignType IN (
        '02608', -- 6-12 school
        '02605', -- Adult education school
        '02609', -- Alternative school
        '02604', -- Career-technology education center
        '02599', -- Early childhood center
        '02600', -- Elementary school
        '02602', -- Junior high school
        '02607', -- K-8 school
        '02601', -- Middle school
        '13638', -- Performing arts school
        '13639', -- Science, technology, engineering and math (STEM) school
        '02603', -- Senior high school
        '02606', -- Special education school
        '09999' -- Other
    )),
    BuildingScienceSpecialtySpaceType TEXT CHECK (BuildingScienceSpecialtySpaceType IN (
        '02661', -- Biology laboratory
        '02668', -- Chemical storage room
        '02662', -- Chemistry laboratory
        '02663', -- Environmental science laboratory
        '02670', -- General science laboratory
        '02669', -- Miscellaneous storage room
        '02435', -- Outdoor classroom
        '02664', -- Physics laboratory
        '02665', -- Planetarium
        '02666', -- Prep room
        '02667', -- Science lecture room
        '09999' -- Other
    )),
    BuildingSiteImprovementDescription TEXT, -- Description of site improvements
    BuildingSpaceDesignType TEXT CHECK (BuildingSpaceDesignType IN (
        '02633', -- Administration
        '02634', -- Assembly
        '02631', -- Athletic
        '02628', -- Basic classroom
        '02635', -- Corridors
        '02639', -- Dormitory room
        '02638', -- Food service
        '02630', -- Library/media
        '02773', -- Multi-purpose Room
        '02636', -- Operational support
        '03017', -- Restroom
        '02629', -- Specialty classroom
        '02637', -- Storage
        '02788', -- Storage - hazardous materials
        '02632', -- Student support
        '09999' -- Other
    )),
    BuildingSpecialEducationSpecialtySpaceType TEXT CHECK (BuildingSpecialEducationSpecialtySpaceType IN (
        '02674', -- IEP conference room
        '02675', -- Itinerant staff room
        '02671', -- Occupational therapy room
        '02673', -- Physical therapy room
        '03107', -- Resource room
        '02676', -- Self-contained classroom
        '02672', -- Speech and hearing room
        '09999' -- Other
    )),
    BuildingStudentSupportSpaceType TEXT CHECK (BuildingStudentSupportSpaceType IN (
        '02738', -- Career center
        '02739', -- College center
        '02737', -- Guidance/counseling room
        '02736', -- Health room lavatory
        '02735', -- Health suite
        '02733', -- In-school suspension room
        '02740', -- Internship center
        '02734', -- Nurse's station
        '02741', -- Student club space
        '09999' -- Other
    )),
    FacilityComplianceDeterminationDate DATE, -- Date compliance status determined
    FacilityComplianceName TEXT, -- Name of inspection process
    FacilityComponentDeficiencyDescription TEXT, -- Description of component deficiency
    FacilityComponentIdentificationCode TEXT, -- Unique component identifier
    FacilityEstimatedCostToEliminateDeferredMaintenance REAL, -- Cost to eliminate deferred maintenance
    FacilityFurnishingsType TEXT CHECK (FacilityFurnishingsType IN (
        '00103', -- Administrative office
        '02792', -- Cafeteria
        '03014', -- Classroom
        '00309', -- Occupational therapy
        '00559', -- Physical education
        '00313' -- Physical therapy
    )),
    FacilityHazardousConditionExpectedRemediationDate DATE, -- Expected remediation date
    FacilityInspectionScoreResultDescription TEXT, -- Description of inspection score
    FacilityInspectionViolationDescription TEXT, -- Description of violations
    FacilitySiteOutdoorAreaType TEXT CHECK (FacilitySiteOutdoorAreaType IN (
        '13566', -- Athletic field - Artificial
        '02434', -- Athletic field - Natural
        '02438', -- Drop-off/driveway
        '02526', -- Fencing enclosures
        '02437', -- Hardscape game area
        '02436', -- Hardscape play area
        '02443', -- Landscaping
        '02524', -- Parking area
        '02433', -- Playground
        '02440', -- Retaining walls
        '13567', -- Semi-permeable game area
        '02439', -- Septic fields
        '02441', -- Sidewalks
        '13568', -- Softscape game area
        '13569', -- Softscape play area
        '02442', -- Stairs and ramps
        '02444' -- Water filtration system
    )),
    FacilitySpaceDescription TEXT, -- Description of space layout
    HazardousMaterialOrConditionDescription TEXT, -- Description of hazardous material threat
    HazardousMaterialOrConditionTestingDate DATE, -- Date tested for hazardous material
    InstallationDate DATE, -- Date system/component installed
    LifeCycleCost REAL, -- Total cost over useful life
    FacilitySiteImprovementLocationType TEXT CHECK (FacilitySiteImprovementLocationType IN (
        '02434', -- Athletic field - Natural
        '02438', -- Drop-off/driveway
        '02526', -- Fencing enclosures
        '02437', -- Hardscape game area
        '02436', -- Hardscape play area
        '02443', -- Landscaping
        '02435', -- Outdoor classroom
        '02524', -- Parking area
        '02433', -- Playground
        '02440', -- Retaining walls
        '02439', -- Septic fields
        '02441', -- Sidewalks
        '02442', -- Stairs and ramps
        '02444', -- Water filtration system
        '09999' -- Other
    ))
);

-- Creating table for Facility Management entity
CREATE TABLE FacilityManagement (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    BuildingCharterSchoolRealtyAccessType TEXT CHECK (BuildingCharterSchoolRealtyAccessType IN (
        '13691', -- Leasehold
        '13692', -- Ownership by Charter Non-Profit Corporation
        '13693', -- Third Party Non-Profit Ownership
        '14907' -- Third-party public sector ownership
    )),
    BuildingCleaningStandardType TEXT CHECK (BuildingCleaningStandardType IN (
        '02831', -- Level 1 cleaning
        '02832', -- Level 2 cleaning
        '02833', -- Level 3 cleaning
        '02834', -- Level 4 cleaning
        '02835' -- Level 5 cleaning
    )),
    BuildingDateOfCertificateOfOccupancy DATE, -- Date certificate granted
    BuildingEnergyConservationMeasureType TEXT CHECK (BuildingEnergyConservationMeasureType IN (
        '13653', -- Daylighting
        '13654', -- Delamping
        '02848', -- HVAC replacement
        '02847', -- Installation of energy controls
        '14904', -- Installation of solar equipment
        '02850', -- Insulation improvements
        '02849', -- Lighting replacement
        '14903', -- Relamping
        '02846', -- Window replacement
        '09999' -- Other
    )),
    BuildingEnergyServiceCompanyName TEXT, -- Name of energy service company
    BuildingEnergySourceType TEXT CHECK (BuildingEnergySourceType IN (
        '13655', -- Biomass
        '02858', -- Coal
        '02854', -- Electric
        '02853', -- Gas
        '02857', -- Geothermal
        '02859', -- Nuclear
        '02842', -- Oil
        '02855', -- Solar
        '02843', -- Water
        '02856', -- Wind
        '09999' -- Other
    )),
    FacilitiesManagementEmergencyType TEXT CHECK (FacilitiesManagementEmergencyType IN (
        '02882', -- Act of violence
        '02880', -- Bomb threat
        '02888', -- Debris flows or mudslide
        '02886', -- Earthquake
        '02895', -- Emergency shelter need
        '02892', -- Extreme heat
        '02878', -- Fire
        '02897', -- Flood
        '02894', -- Gas leak
        '02883', -- Hostage
        '02884', -- Hurricane and tropical storm
        '02893', -- Major chemical emergency
        '02881', -- Terrorism
        '02879', -- Theft
        '02885', -- Thunderstorm - severe
        '02896', -- Tornado
        '02889', -- Tsunami
        '02890', -- Volcano
        '02891', -- Wildfire - surface, ground, or crown fire
        '02887', -- Winter storm
        '09999' -- Other
    )),
    FacilitiesMandateAuthorityType TEXT CHECK (FacilitiesMandateAuthorityType IN (
        '13390', -- District/Local
        '00859', -- Federal
        '00391' -- State
    )),
    FacilitiesPlanDescription TEXT, -- Description of management plan
    FacilitiesPlanType TEXT CHECK (FacilitiesPlanType IN (
        '02828', -- Capital improvement plan
        '02827', -- Educational facilities master plan
        '02825', -- Emergency response plan
        '02829', -- Energy management plan
        '02830', -- Hazardous materials management plan
        '02826', -- Maintenance plan
        '09999' -- Other
    )),
    FacilityAuditDate DATE, -- Date of facility audit
    FacilityAuditType TEXT CHECK (FacilityAuditType IN (
        '02979', -- Building commissioning
        '02977', -- Financial audit
        '02980', -- Fiscal audit
        '02976', -- Management audit
        '02978', -- Performance audit
        '13688', -- Post Occupancy Evaluation
        '02981', -- Process audit
        '13687', -- Retro-commissioning
        '09999' -- Other
    )),
    FacilityCapitalProgramManagementType TEXT CHECK (FacilityCapitalProgramManagementType IN (
        '02913', -- District management
        '02824', -- Nonschool public agency management
        '02823', -- Private management
        '09999' -- Other
    )),
    FacilityComplianceAgencyType TEXT CHECK (FacilityComplianceAgencyType IN (
        '00865', -- Charter board
        '13652', -- Federal Agency
        '00862', -- Local (e.g., school board, city council)
        '00864', -- Private/Religious
        '00214', -- Regional or intermediate educational agency
        '00860' -- State agency
    )),
    FacilityHazardousMaterialsOrConditionType TEXT CHECK (FacilityHazardousMaterialsOrConditionType IN (
        '02898', -- Asbestos
        '13656', -- Carbon Monoxide
        '13657', -- Chlorofluorocarbons
        '13658', -- Concentrated animal feeding operations (CAFOs)
        '13659', -- Criteria Air Pollutants
        '13660', -- Drip Lines
        '13661', -- Ground Level Ozone
        '13662', -- Hazardous Air Pollutants
        '13663', -- Hazardous, industrial, or municipal waste sites
        '13664', -- Hydrochlorofluorocarbons
        '02899', -- Lead
        '13665', -- Mercury
        '13666', -- Methane
        '02900', -- Mold
        '13667', -- Nitrogen Oxides
        '13668', -- Particulate Matter
        '02903', -- Pesticides
        '13669', -- Polychlorinated biphenyls (PCBs)
        '13670', -- Propellants
        '02902', -- Radon
        '13671', -- Refrigerants
        '13672', -- Sediment, sludge, reuse material
        '13673', -- Sulfur dioxide
        '02901', -- Underground storage tanks (USTs)
        '13674', -- Vapor intrusion
        '13675', -- Volatile organic compounds
        '09999' -- Other
    )),
    FacilityJointDevelopmentType TEXT CHECK (FacilityJointDevelopmentType IN (
        '13690', -- Dedicated
        '13689' -- Shared
    )),
    FacilityMaintenanceStandardType TEXT CHECK (FacilityMaintenanceStandardType IN (
        '02989', -- Emergency maintenance repair
        '02839', -- Predictive
        '02838', -- Preventive
        '02837', -- Routine
        '02836' -- Run to fail
    )),
    FacilityNaturallyOccurringHazardType TEXT CHECK (FacilityNaturallyOccurringHazardType IN (
        '13678', -- Arsenic
        '13679', -- Earthquake prone area
        '13680', -- Floodplain
        '13681', -- Liquefaction, landslide areas
        '13682', -- Naturally Occurring Asbestos (NOA)
        '13683' -- Sinkholes, Karst terrain
    )),
    FacilityOperationsManagementType TEXT CHECK (FacilityOperationsManagementType IN (
        '02821', -- District and private sector management
        '02822', -- Nonschool public sector management
        '02820', -- Private sector management
        '02819', -- School district management
        '09999' -- Other
    )),
    FacilityStandardType TEXT CHECK (FacilityStandardType IN (
        '02622', -- Design guidelines
        '02626', -- Energy performance standards
        '13628', -- Environmental Standards
        '02625', -- Health and safety standards
        '02624', -- Master construction specifications
        '02627', -- Site selection guidelines
        '02623', -- Space standards
        '09999' -- Other
    )),
    FacilityUtilityProviderType TEXT CHECK (FacilityUtilityProviderType IN (
        '02852', -- Purchased
        '02851' -- Self-generated
    )),
    FacilityUtilityType TEXT CHECK (FacilityUtilityType IN (
        '02840', -- Electricity
        '02990', -- Internet service
        '02841', -- Natural gas
        '02842', -- Oil
        '13685', -- Recycling
        '02844', -- Sewer
        '02845', -- Telephone
        '13686', -- Waste
        '02843', -- Water
        '09999' -- Other
    ))
);

-- Creating table for Facility Utilization entity
CREATE TABLE FacilityUtilization (
    FacilitiesIdentifier TEXT NOT NULL, -- References Facility table
    AdjustedCapacity INTEGER, -- Maximum participants in program
    AdjustedCapacityReasonType TEXT CHECK (AdjustedCapacityReasonType IN (
        '100', -- COVID-19
        '999' -- Other
    )),
    AvailableUtilizedInstructionalSpace TEXT CHECK (AvailableUtilizedInstructionalSpace IN ('Yes', 'No')),
    BuildingCapacityFactorIndicator TEXT CHECK (BuildingCapacityFactorIndicator IN ('Yes', 'No')),
    BuildingCommunityUseSpaceType TEXT CHECK (BuildingCommunityUseSpaceType IN (
        '02764', -- Before- and after-school care
        '02760', -- Before- and after-school office
        '02761', -- Child care and development space
        '02765', -- Community room
        '02767', -- Family resource center
        '02766', -- Full-service health clinic
        '02987', -- Head Start space
        '02762', -- Health clinic
        '02763', -- Parent room
        '09999' -- Other
    )),
    BuildingHoursOfPublicUsePerWeek INTEGER, -- Hours used by community per week
    BuildingInstructionalSpaceFactorType TEXT CHECK (BuildingInstructionalSpaceFactorType IN (
        '02811', -- Instructional space
        '02812' -- Noninstructional space
    )),
    BuildingJointUseRationaleType TEXT CHECK (BuildingJointUseRationaleType IN (
        '13710', -- Increase programs and services for students
        '13711', -- Increase programs and services for community
        '13712', -- Increase utilization of under used space
        '13709' -- Raise revenue
    )),
    BuildingJointUseSchedulingType TEXT CHECK (BuildingJointUseSchedulingType IN (
        '13694', -- Drop-in use
        '13697', -- Long term lease
        '13695', -- One-time event use
        '13696' -- Short-term lease
    )),
    BuildingJointUserType TEXT CHECK (BuildingJointUserType IN (
        '13705', -- Civic groups
        '13704', -- Individuals
        '13706', -- Other public agencies
        '13708', -- Private for-profit corporations
        '13707' -- Private non-profit organizations
    )),
    BuildingNetAreaOfInstructionalSpace REAL, -- Area directly used for instruction
    BuildingNumberOfTeachingStations INTEGER, -- Number of teaching stations
    BuildingPublicUsePolicyDescription TEXT, -- Policy for community use
    BuildingSiteUseRestrictionsType TEXT CHECK (BuildingSiteUseRestrictionsType IN (
        '02446', -- Enterprise zone
        '02449', -- Environmental contamination
        '02448', -- Environmental protection
        '02447', -- Historic district
        '02445', -- Land use
        '02450', -- Site easements
        '09999' -- Other
    )),
    BuildingSpaceUtilizationArea REAL, -- Area between principal walls
    BuildingUnassignedSpaceIndicator TEXT CHECK (BuildingUnassignedSpaceIndicator IN ('Yes', 'No')),
    BuildingUseType TEXT CHECK (BuildingUseType IN (
        '13700', -- Administration building
        '13699', -- Alternative school
        '02621', -- Assembly building
        '02614', -- Central kitchen building
        '02803', -- Chapel building
        '02619', -- Dormitory building
        '02616', -- Field house building
        '02613', -- Garage building
        '13698', -- Grade level school
        '02620', -- Gymnasium building
        '02806', -- Holding school
        '02804', -- Investment
        '02617', -- Media production center building
        '02618', -- Natatorium
        '02805', -- Not in use
        '02611', -- Office building
        '02802', -- Operations building
        '03106', -- School building
        '02610', -- Service center building
        '02615', -- Stadium building
        '02612', -- Warehouse building
        '09999' -- Other
    )),
    EnrollmentCapacity INTEGER, -- Maximum age-appropriate students
    FacilityEnrollmentCapacity INTEGER, -- Maximum students meeting requirements
    FacilityJointUseDescription TEXT, -- Details of shared facility arrangement
    FacilityJointUseIndicator TEXT CHECK (FacilityJointUseIndicator IN ('Yes', 'No')),
    FacilitySpaceUseType TEXT CHECK (FacilitySpaceUseType IN (
        '02633', -- Administration
        '02634', -- Assembly
        '02631', -- Athletic
        '02628', -- Basic classroom
        '02635', -- Corridors
        '02639', -- Dormitory room
        '02638', -- Food service
        '02630', -- Library/media
        '02773', -- Multi-purpose room
        '02636', -- Operational support
        '03017', -- Restroom
        '02629', -- Specialty classroom
        '02637', -- Storage
        '02788', -- Storage - hazardous materials
        '02632', -- Student support
        '09999' -- Other
    ))
);

-- Creating table for Early Learning Child entity
CREATE TABLE EarlyLearningChild (
    ChildIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    ChildIdentificationSystem TEXT CHECK (ChildIdentificationSystem IN (
        'CanadianSIN', -- Canadian Social Insurance Number
        'District', -- District-assigned number
        'Family', -- Family unit number
        'Federal', -- Federal identification number
        'NationalMigrant', -- National migrant number
        'School', -- School-assigned number
        'SSN', -- Social Security Administration number
        'State', -- State-assigned number
        'StateMigrant', -- State migrant number
        'Program', -- Program-assigned number
        'BirthCertificate' -- Birth certificate number
    )),
    Birthdate DATE, -- Date of birth
    Sex TEXT CHECK (Sex IN (
        'Male', -- Male
        'Female', -- Female
        'NotSelected' -- Not selected
    )),
    AmericanIndianOrAlaskaNative TEXT CHECK (AmericanIndianOrAlaskaNative IN ('Yes', 'No', 'NotSelected')),
    Asian TEXT CHECK (Asian IN ('Yes', 'No', 'NotSelected')),
    BlackOrAfricanAmerican TEXT CHECK (BlackOrAfricanAmerican IN ('Yes', 'No', 'NotSelected')),
    NativeHawaiianOrOtherPacificIslander TEXT CHECK (NativeHawaiianOrOtherPacificIslander IN ('Yes', 'No', 'NotSelected')),
    White TEXT CHECK (White IN ('Yes', 'No', 'NotSelected')),
    HispanicOrLatinoEthnicity TEXT CHECK (HispanicOrLatinoEthnicity IN ('Yes', 'No', 'NotSelected')),
    DemographicRaceTwoOrMoreRaces TEXT CHECK (DemographicRaceTwoOrMoreRaces IN ('Yes', 'No')),
    Race TEXT CHECK (Race IN (
        'AmericanIndianOrAlaskaNative', -- American Indian or Alaska Native
        'Asian', -- Asian
        'BlackOrAfricanAmerican', -- Black or African American
        'DemographicRaceTwoOrMoreRaces', -- Demographic Race Two or More Races
        'NativeHawaiianOrOtherPacificIslander', -- Native Hawaiian or Other Pacific Islander
        'RaceAndEthnicityUnknown', -- Race and Ethnicity Unknown
        'White' -- White
    )),
    FederalRaceAndEthnicityDeclined TEXT CHECK (FederalRaceAndEthnicityDeclined IN ('Yes', 'No')),
    CountryOfBirthCode TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    StateOfBirthAbbreviation TEXT CHECK (StateOfBirthAbbreviation IN (
        'AK', -- Alaska
        'AL', -- Alabama
        'AR', -- Arkansas
        'AS', -- American Samoa
        'AZ', -- Arizona
        'CA', -- California
        'CO', -- Colorado
        'CT', -- Connecticut
        'DC', -- District of Columbia
        'DE', -- Delaware
        'FL', -- Florida
        'FM', -- Federated States of Micronesia
        'GA', -- Georgia
        'GU', -- Guam
        'HI', -- Hawaii
        'IA', -- Iowa
        'ID', -- Idaho
        'IL', -- Illinois
        'IN', -- Indiana
        'KS', -- Kansas
        'KY', -- Kentucky
        'LA', -- Louisiana
        'MA', -- Massachusetts
        'MD', -- Maryland
        'ME', -- Maine
        'MH', -- Marshall Islands
        'MI', -- Michigan
        'MN', -- Minnesota
        'MO', -- Missouri
        'MP', -- Northern Marianas
        'MS', -- Mississippi
        'MT', -- Montana
        'NC', -- North Carolina
        'ND', -- North Dakota
        'NE', -- Nebraska
        'NH', -- New Hampshire
        'NJ', -- New Jersey
        'NM', -- New Mexico
        'NV', -- Nevada
        'NY', -- New York
        'OH', -- Ohio
        'OK', -- Oklahoma
        'OR', -- Oregon
        'PA', -- Pennsylvania
        'PR', -- Puerto Rico
        'PW', -- Palau
        'RI', -- Rhode Island
        'SC', -- South Carolina
        'SD', -- South Dakota
        'TN', -- Tennessee
        'TX', -- Texas
        'UT', -- Utah
        'VA', -- Virginia
        'VI', -- Virgin Islands
        'VT', -- Vermont
        'WA', -- Washington
        'WI', -- Wisconsin
        'WV', -- West Virginia
        'WY' -- Wyoming
    )),
    TribalAffiliation TEXT, -- Native American tribal entity
    HomelessnessStatus TEXT CHECK (HomelessnessStatus IN ('Yes', 'No')),
    MigrantStatus TEXT CHECK (MigrantStatus IN ('Yes', 'No')),
    MilitaryConnectedStudentIndicator TEXT CHECK (MilitaryConnectedStudentIndicator IN (
        'NotMilitaryConnected', -- Not Military Connected
        'ActiveDuty', -- Active Duty
        'NationalGuardOrReserve', -- National Guard Or Reserve
        'Unknown' -- Unknown
    )),
    OtherRaceIndicator TEXT CHECK (OtherRaceIndicator IN ('Yes', 'No')),
    PublicSchoolResidenceStatus TEXT CHECK (PublicSchoolResidenceStatus IN (
        '01652', -- Resident of administrative unit and usual school attendance area
        '01653', -- Resident of administrative unit, but of other school attendance area
        '01654', -- Resident of this state, but not of this administrative unit
        '01655', -- Resident of an administrative unit that crosses state boundaries
        '01656' -- Resident of another state
    )),
    AddressApartmentRoomOrSuiteNumber TEXT, -- Apartment, room, or suite number
    AddressStreetNumberAndName TEXT, -- Street number and name or PO box
    AddressCity TEXT, -- City name
    AddressCountyName TEXT, -- County name
    AddressPostalCode TEXT, -- Postal code
    AddressTypeForLearnerOrFamily TEXT CHECK (AddressTypeForLearnerOrFamily IN (
        'Mailing', -- Mailing
        'Physical', -- Physical
        'Shipping', -- Shipping
        'Billing', -- Billing address
        'OnCampus', -- On campus
        'OffCampus', -- Off-campus, temporary
        'PermanentStudent', -- Permanent, student
        'PermanentAdmission', -- Permanent, at time of admission
        'FatherAddress', -- Father's address
        'MotherAddress', -- Mother's address
        'GuardianAddress' -- Guardian's address
    )),
    CountryCode TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    CountyANSICode TEXT, -- ANSI county code, see https://www.census.gov/library/reference/code-lists/ansi.html#par_statelist
    DoNotPublishIndicator TEXT CHECK (DoNotPublishIndicator IN ('Yes', 'No', 'Unknown')),
    ElectronicMailAddress TEXT, -- Email address
    ElectronicMailAddressType TEXT CHECK (ElectronicMailAddressType IN (
        'Home', -- Home/personal
        'Work', -- Work
        'Organizational', -- Organizational address
        'Other' -- Other
    )),
    Latitude REAL, -- North/south angular distance
    Longitude REAL, -- East/west angular distance
    TelephoneNumber TEXT, -- Telephone number with area code
    TelephoneNumberType TEXT CHECK (TelephoneNumberType IN (
        'Home', -- Home phone number
        'Work', -- Work phone number
        'Mobile', -- Mobile phone number
        'Fax', -- Fax number
        'Other' -- Other
    )),
    TelephoneNumberListedStatus TEXT CHECK (TelephoneNumberListedStatus IN (
        'Listed', -- Listed
        'Unknown', -- Unknown
        'Unlisted' -- Unlisted
    )),
    PrimaryTelephoneNumberIndicator TEXT CHECK (PrimaryTelephoneNumberIndicator IN ('Yes', 'No')),
    InternetDownloadSpeed REAL, -- Download speed in Mbps
    InternetUploadSpeed REAL, -- Upload speed in Mbps
    InternetSpeedTestDateTime TEXT, -- Date and time of speed test
    AwaitingInitialIDEAEvaluationStatus TEXT CHECK (AwaitingInitialIDEAEvaluationStatus IN ('Yes', 'No')),
    DisabilityStatus TEXT CHECK (DisabilityStatus IN ('Yes', 'No')),
    IDEAIndicator TEXT CHECK (IDEAIndicator IN ('Yes', 'No')),
    Section504Status TEXT CHECK (Section504Status IN ('Yes', 'No')),
    PrimaryDisabilityType TEXT CHECK (PrimaryDisabilityType IN (
        'AUT', -- Autism
        'DB', -- Deaf-blindness
        'DD', -- Developmental delay
        'EMN', -- Emotional disturbance
        'HI', -- Hearing impairment
        'ID', -- Intellectual Disability
        'MD', -- Multiple disabilities
        'OI', -- Orthopedic impairment
        'OHI', -- Other health impairment
        'SLD', -- Specific learning disability
        'SLI', -- Speech or language impairment
        'TBI', -- Traumatic brain injury
        'VI' -- Visual impairment
    )),
    DisabilityConditionType TEXT CHECK (DisabilityConditionType IN (
        '00', -- No disability or impairment known or reported
        '01', -- Blindness or Visual Impairment
        '02', -- Cerebral Palsy
        '03', -- Chronic Illness
        '04', -- Deafness or Hearing Impairment
        '05', -- Drug or Alcohol Addiction
        '06', -- Emotionally/Psychologically Disabled
        '07', -- Epilepsy or Seizure Disorders
        '08', -- Intellectual Disability
        '09', -- Orthopedic Impairment
        '10', -- Specific learning disability
        '11', -- Speech or Language impairment
        '99' -- Other type of impairment
    )),
    DisabilityDeterminationSourceType TEXT CHECK (DisabilityDeterminationSourceType IN (
        '01', -- By physician
        '02', -- By health care provider
        '03', -- By school psychologist or other psychologist
        '04', -- By licensed physical therapist
        '05', -- Self-reported
        '06', -- By social service or other agency
        '97', -- Not applicable to the student
        '98', -- Unknown or Unreported
        '99' -- Other
    )),
    IDEAEducationalEnvironmentForEarlyChildhood TEXT CHECK (IDEAEducationalEnvironmentForEarlyChildhood IN (
        'REC09YOTHLOC', -- Other location regular early childhood program (less than 10 hours)
        'REC10YOTHLOC', -- Other location regular early childhood program (at least 10 hours)
        'REC09YSVCS', -- Services regular early childhood program (less than 10 hours)
        'REC10YSVCS', -- Services regular early childhood program (at least 10 hours)
        'SC', -- Separate special education class
        'SS', -- Separate school
        'RF', -- Residential Facility
        'H', -- Home
        'SPL' -- Service provider or other location not in any other category
    )),
    EarlyLearningProgramEligibilityCategory TEXT CHECK (EarlyLearningProgramEligibilityCategory IN (
        'Age', -- Age
        'FamilyIncome', -- Family income
        'DisabilityStatus', -- Disability Status
        'SSSI', -- Supplemental social security income
        'WIC', -- Women, infants, and children
        'TANF', -- Temporary assistance for needy families
        'OtherPublicAssistance', -- Other public assistance
        'Foster', -- Foster
        'MilitaryFamily', -- Military family
        'ELL', -- Home language other than English
        'OtherFamilyRisk', -- Other family risk factors
        'OtherChildRisk', -- Other child risk factors
        'AtRisk', -- At-risk of developing delay
        'Other' -- Other
    )),
    EarlyLearningProgramEligibilityStatus TEXT CHECK (EarlyLearningProgramEligibilityStatus IN (
        'Pending', -- Pending
        'NotEligible', -- Not found eligible
        'Eligible', -- Found eligible
        'NotActive' -- Not yet active
    )),
    EarlyLearningProgramEligibilityStatusDate DATE, -- Date of eligibility status
    EarlyLearningProgramEligibilityExpirationDate DATE, -- Date eligibility expires
    EnglishLearnerStatus TEXT CHECK (EnglishLearnerStatus IN ('Yes', 'No')),
    ApplicationDate DATE, -- Date application received
    EnrollmentDate DATE, -- Date officially enrolled
    EnrollmentEntryDate DATE, -- Date began receiving services
    EnrollmentExitDate DATE, -- Date enrollment ended
    ExitReason TEXT CHECK (ExitReason IN (
        '06262', -- Attempts to contact parent/child unsuccessful
        '02226', -- Completion of IFSP prior to max age for Part C
        '01923', -- Died or permanently incapacitated
        '01927', -- Discontinued schooling
        '02222', -- Discontinued schooling, not special education
        '02221', -- Discontinued schooling, special education only
        '02227', -- Eligible for IDEA, Part B
        '02224', -- Expulsion
        '02212', -- Graduated with high school diploma
        '02231', -- Moved out of state
        '02216', -- No longer receiving special education
        '73075', -- Moved within US, not known to be continuing
        '06261', -- Not eligible for Part B, no referrals
        '02228', -- Not eligible for Part B, with referrals
        '02230', -- Part B eligibility not determined
        '02214', -- Program completion
        '02225', -- Program discontinued
        '02215', -- Reached maximum age
        '02213', -- Received certificate of completion
        '02217', -- Refused services
        '73076', -- Student data claimed in error
        '73078', -- Moved to another country
        '73079', -- Remaining for transitional services
        '02220', -- Suspended from school
        '02406', -- Transferred, not continuing
        '02218', -- Transferred, continuing
        '02219', -- Transferred, not known to continue
        '73077', -- Transferred to correctional facility
        '02233', -- Unknown reason
        '02232', -- Withdrawal by parent/guardian
        '09999' -- Other
    )),
    NumberOfDaysAbsent INTEGER, -- Days absent during reporting period
    NumberOfDaysInAttendance INTEGER, -- Days present during reporting period
    ChildDevelopmentalScreeningStatus TEXT CHECK (ChildDevelopmentalScreeningStatus IN (
        'FurtherEvaluationNeeded', -- Further evaluation needed
        'NoFurtherEvaluationNeeded', -- No further evaluation needed
        'NoScreeningPerformed', -- No Screening Performed
        'AssessmentToolUnavailable', -- Appropriate Assessment Tool Unavailable
        'PersonnelUnavailable' -- Personnel Unavailable
    )),
    DevelopmentalEvaluationFinding TEXT CHECK (DevelopmentalEvaluationFinding IN (
        'Adaptive', -- Adaptive development delay
        'Cognitive', -- Cognitive development delay
        'Communication', -- Communication development delay
        'NoDelay', -- No delay, needs follow-up
        'None', -- None
        'Physical', -- Physical development delay
        'SocialEmotional', -- Social or emotional development delay
        'NoDelayDetected', -- No delay detected
        'EstablishedCondition', -- Established condition
        'AtRisk' -- At-risk of developing delay
    )),
    AssessmentEarlyLearningDevelopmentalDomain TEXT CHECK (AssessmentEarlyLearningDevelopmentalDomain IN (
        '01', -- Language and Literacy
        '02', -- Cognition and General Knowledge
        '03', -- Approaches Toward Learning
        '04', -- Physical Well-being and Motor
        '05' -- Social and Emotional Development
    )),
    AssessmentLevelForWhichDesigned TEXT CHECK (AssessmentLevelForWhichDesigned IN (
        'Birth', -- Birth
        'Prenatal', -- Prenatal
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    ISO6392LanguageCode TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    ISO6393LanguageCode TEXT, -- ISO 639-3 language code, see http://www-01.sil.org/iso639-3/default.asp
    ISO6395LanguageFamily TEXT CHECK (ISO6395LanguageFamily IN (
        'aav', -- Austro-Asiatic languages
        'afa', -- Afro-Asiatic languages
        'alg', -- Algonquian languages
        'alv', -- Atlantic-Congo languages
        'apa', -- Apache languages
        'aqa', -- Alacalufan languages
        'aql', -- Algic languages
        'art', -- Artificial languages
        'ath', -- Athapascan languages
        'auf', -- Arauan languages
        'aus', -- Australian languages
        'awd', -- Arawakan languages
        'azc', -- Uto-Aztecan languages
        'bad', -- Banda languages
        'bai', -- Bamileke languages
        'bat', -- Baltic languages
        'ber', -- Berber languages
        'bih', -- Bihari languages
        'bnt', -- Bantu languages
        'btk', -- Batak languages
        'cai', -- Central American Indian languages
        'cau', -- Caucasian languages
        'cba', -- Chibchan languages
        'ccn', -- North Caucasian languages
        'ccs', -- South Caucasian languages
        'cdc', -- Chadic languages
        'cdd', -- Caddoan languages
        'cel', -- Celtic languages
        'cmc', -- Chamic languages
        'cpe', -- Creoles and pidgins, English-based
        'cpf', -- Creoles and pidgins, French-based
        'cpp', -- Creoles and pidgins, Portuguese-based
        'crp', -- Creoles and pidgins
        'csu', -- Central Sudanic languages
        'cus', -- Cushitic languages
        'day', -- Land Dayak languages
        'dmn', -- Mande languages
        'dra', -- Dravidian languages
        'egx', -- Egyptian languages
        'esx', -- Eskimo-Aleut languages
        'euq', -- Basque (family)
        'fiu', -- Finno-Ugrian languages
        'fox', -- Formosan languages
        'gem', -- Germanic languages
        'gme', -- East Germanic languages
        'gmq', -- North Germanic languages
        'gmw', -- West Germanic languages
        'grk', -- Greek languages
        'hmx', -- Hmong-Mien languages
        'hok', -- Hokan languages
        'hyx', -- Armenian (family)
        'iir', -- Indo-Iranian languages
        'ijo', -- Ijo languages
        'inc', -- Indic languages
        'ine', -- Indo-European languages
        'ira', -- Iranian languages
        'iro', -- Iroquoian languages
        'itc', -- Italic languages
        'jpx', -- Japanese (family)
        'kar', -- Karen languages
        'kdo', -- Kordofanian languages
        'khi', -- Khoisan languages
        'kro', -- Kru languages
        'map', -- Austronesian languages
        'mkh', -- Mon-Khmer languages
        'mno', -- Manobo languages
        'mun', -- Munda languages
        'myn', -- Mayan languages
        'nah', -- Nahuatl languages
        'nai', -- North American Indian languages
        'ngf', -- Trans-New Guinea languages
        'nic', -- Niger-Kordofanian languages
        'nub', -- Nubian languages
        'omq', -- Oto-Manguean languages
        'omv', -- Omotic languages
        'oto', -- Otomian languages
        'paa', -- Papuan languages
        'phi', -- Philippine languages
        'plf', -- Central Malayo-Polynesian languages
        'poz', -- Malayo-Polynesian languages
        'pqe', -- Eastern Malayo-Polynesian languages
        'pqw', -- Western Malayo-Polynesian languages
        'pra', -- Prakrit languages
        'qwe', -- Quechuan (family)
        'roa', -- Romance languages
        'sai', -- South American Indian languages
        'sal', -- Salishan languages
        'sdv', -- Eastern Sudanic languages
        'sem', -- Semitic languages
        'sgn', -- Sign languages
        'sio', -- Siouan languages
        'sit', -- Sino-Tibetan languages
        'sla', -- Slavic languages
        'smi', -- Sami languages
        'son', -- Songhai languages
        'sqj', -- Albanian languages
        'ssa', -- Nilo-Saharan languages
        'syd', -- Samoyedic languages
        'tai', -- Tai languages
        'tbq', -- Tibeto-Burman languages
        'trk', -- Turkic languages
        'tup', -- Tupi languages
        'tut', -- Altaic languages
        'tuw', -- Tungus languages
        'urj', -- Uralic languages
        'wak', -- Wakashan languages
        'wen', -- Sorbian languages
        'xgn', -- Mongolian languages
        'xnd', -- Na-Dene languages
        'ypk', -- Yupik languages
        'zhx', -- Chinese (family)
        'zle', -- East Slavic languages
        'zls', -- South Slavic languages
        'zlw', -- West Slavic languages
        'znd' -- Zande languages
    )),
    LanguageType TEXT CHECK (LanguageType IN (
        'Correspondence', -- Correspondence
        'Dominant', -- Dominant language
        'Home', -- Home language
        'Native', -- Native language
        'OtherLanguageProficiency', -- Other language proficiency
        'Other', -- Other
        'Spoken', -- Spoken Correspondence
        'Written' -- Written Correspondence
    ))
);

-- Creating table for Child Outcome Summary entity
CREATE TABLE ChildOutcomeSummary (
    ChildIdentifier TEXT NOT NULL, -- References EarlyLearningChild table
    COSProgressAIndicator TEXT CHECK (COSProgressAIndicator IN ('Yes', 'No')),
    COSProgressBIndicator TEXT CHECK (COSProgressBIndicator IN ('Yes', 'No')),
    COSProgressCIndicator TEXT CHECK (COSProgressCIndicator IN ('Yes', 'No')),
    COSRatingA TEXT CHECK (COSRatingA IN (
        '01', -- Does not show expected functioning
        '02', -- Occasionally uses foundational skills
        '03', -- Uses immediate foundational skills
        '04', -- Occasional age-appropriate functioning
        '05', -- Expected functioning some of the time
        '06', -- Generally age-appropriate with concerns
        '07' -- Expected functioning in all situations
    )),
    COSRatingB TEXT CHECK (COSRatingB IN (
        '01', -- Does not show expected functioning
        '02', -- Occasionally uses foundational skills
        '03', -- Uses immediate foundational skills
        '04', -- Occasional age-appropriate functioning
        '05', -- Expected functioning some of the time
        '06', -- Generally age-appropriate with concerns
        '07' -- Expected functioning in all situations
    )),
    COSRatingC TEXT CHECK (COSRatingC IN (
        '01', -- Does not show expected functioning
        '02', -- Occasionally uses foundational skills
        '03', -- Uses immediate foundational skills
        '04', -- Occasional age-appropriate functioning
        '05', -- Expected functioning some of the time
        '06', -- Generally age-appropriate with concerns
        '07' -- Expected functioning in all situations
    )),
    EarlyLearningOutcomeMeasurementLevel TEXT CHECK (EarlyLearningOutcomeMeasurementLevel IN (
        'Baseline', -- Baseline - at entry
        'AtExit', -- At exit
        'No', -- No
        'Other' -- Other
    )),
    EarlyLearningOutcomeTimePoint TEXT CHECK (EarlyLearningOutcomeTimePoint IN (
        'Baseline', -- Baseline - at entry
        'AtExit', -- At exit
        'NA', -- Not applicable
        'Other' -- Other
    ))
);

-- Creating table for Early Learning Staff entity
CREATE TABLE EarlyLearningStaff (
    PersonIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    PersonIdentificationSystem TEXT CHECK (PersonIdentificationSystem IN (
        'SSN', -- Social Security Administration number
        'USVisa', -- US government Visa number
        'PIN', -- Personal identification number
        'Federal', -- Federal identification number
        'DriversLicense', -- Driver's license number
        'Medicaid', -- Medicaid number
        'HealthRecord', -- Health record number
        'ProfessionalCertificate', -- Professional certificate or license number
        'School', -- School-assigned number
        'District', -- District-assigned number
        'State', -- State-assigned number
        'Institution', -- Institution-assigned number
        'OtherFederal', -- Other federally assigned number
        'SelectiveService', -- Selective Service Number
        'CanadianSIN', -- Canadian Social Insurance Number
        'BirthCertificate', -- Birth certificate number
        'Other' -- Other
    )),
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    Birthdate DATE, -- Date of birth
    Sex TEXT CHECK (Sex IN (
        'Male', -- Male
        'Female', -- Female
        'NotSelected' -- Not selected
    )),
    Race TEXT CHECK (Race IN (
        'AmericanIndianOrAlaskaNative', -- American Indian or Alaska Native
        'Asian', -- Asian
        'BlackOrAfricanAmerican', -- Black or African American
        'DemographicRaceTwoOrMoreRaces', -- Demographic Race Two or More Races
        'NativeHawaiianOrOtherPacificIslander', -- Native Hawaiian or Other Pacific Islander
        'RaceAndEthnicityUnknown', -- Race and Ethnicity Unknown
        'White' -- White
    )),
    CountryOfBirthCode TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    StandardOccupationalClassification TEXT, -- BLS SOC code, see https://www.bls.gov/soc/2018/major_groups.htm
    TribalAffiliation TEXT, -- Native American tribal entity
    HighestLevelOfEducationCompleted TEXT CHECK (HighestLevelOfEducationCompleted IN (
        '01043', -- No school completed
        '00788', -- Preschool
        '00805', -- Kindergarten
        '00790', -- First grade
        '00791', -- Second grade
        '00792', -- Third grade
        '00793', -- Fourth grade
        '00794', -- Fifth grade
        '00795', -- Sixth grade
        '00796', -- Seventh grade
        '00798', -- Eighth grade
        '00799', -- Ninth grade
        '00800', -- Tenth grade
        '00801', -- Eleventh Grade
        '01809', -- 12th grade, no diploma
        '01044', -- High school diploma
        '02408', -- High school completers
        '02409', -- High school equivalency
        '00819', -- Career and Technical Education certificate
        '00803', -- Grade 13
        '01049', -- Some college but no degree
        '01047', -- Formal award, certificate (less than one year)
        '01048', -- Formal award, certificate (one year or more)
        '01050', -- Associate's degree
        '73063', -- Adult education certification
        '01051', -- Bachelor's degree
        '01054', -- Master's degree
        '01055', -- Specialist's degree
        '73081', -- Post-master’s certificate
        '01052', -- Graduate certificate
        '01057', -- Doctoral degree
        '01053', -- First-professional degree
        '01056', -- Post-professional degree
        '73082', -- Doctor’s degree-research/scholarship
        '73083', -- Doctor’s degree-professional practice
        '73084', -- Doctor’s degree-other
        '73085', -- Doctor’s degree-research/scholarship
        '09999' -- Other
    )),
    ActiveMilitaryStatusIndicator TEXT CHECK (ActiveMilitaryStatusIndicator IN (
        'NotActive', -- Not Active
        'Active', -- Active
        'Unknown', -- Unknown
        'NationalGuardOrReserve' -- National Guard Or Reserve
    )),
    MilitaryBranch TEXT CHECK (MilitaryBranch IN (
        'Army', -- Army
        'MarineCorps', -- Marine Corps
        'Navy', -- Navy
        'AirForce', -- Air Force
        'SpaceForce', -- Space Force
        'CoastGuard' -- Coast Guard
    )),
    MilitaryCampaigns TEXT CHECK (MilitaryCampaigns IN (
        'None', -- None
        'GulfWar', -- The Gulf War (1990-1991)
        'IraqWar', -- The Iraq War (2003-2011)
        'KoreanWar', -- The Korean War (1950-1953)
        'VietnamWar', -- The Vietnam War (1955-1975)
        'WarInAfganistan', -- The War in Afghanistan (2001-2021)
        'Unknown', -- Unknown
        'WorldWarII', -- World War II (1939-1945)
        'Other' -- Other
    )),
    MilitaryCountry TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    MilitaryCurrentRank TEXT, -- Current military rank
    MilitaryDeploymentActivityCode TEXT, -- Codes for deployment activities
    MilitaryDeploymentActivityName TEXT, -- Names of deployment activities
    MilitaryDeploymentDescription TEXT, -- Description of deployment
    MilitaryDeploymentEndDate DATE, -- End date of deployment
    MilitaryDeploymentOrderDescription TEXT, -- Description of deployment order
    MilitaryDeploymentRequestedBy TEXT, -- Entity requesting deployment
    MilitaryDeploymentStartDate DATE, -- Start date of deployment
    MilitaryDeploymentStatusCode TEXT CHECK (MilitaryDeploymentStatusCode IN (
        'AvailableForDeployment', -- Available for deployment
        'CurrentlyDeployed', -- Currently deployed
        'NonDeployable', -- Nondeployable
        'PermanentDeploymentExemption', -- Permanent deployment exemption
        'RetiredOrSeparatedFromMilitaryService', -- Retired or separated
        'Temporary exemption from deployment' -- Temporary deployment exemption
    )),
    MilitaryDischargeCategory TEXT CHECK (MilitaryDischargeCategory IN (
        'AdministrativeDischarge', -- Administrative discharge
        'BadConductDischarge', -- Bad conduct discharge
        'DishonorableDischarge', -- Dishonorable discharge
        'EntryLevelSeparation', -- Entry level separation
        'GeneralDischargeUnderHonorableConditions', -- General discharge under honorable
        'HonorableDischarge', -- Honorable discharge
        'MedicalDischarge', -- Medical discharge
        'OtherThanHonorableDischarge', -- Other than honorable discharge
        'RetirementDischarge' -- Retirement discharge
    )),
    MilitaryDischargeDate DATE, -- Date released from military obligations
    MilitaryDischargeRank TEXT, -- Rank at discharge
    MilitaryDuties TEXT CHECK (MilitaryDuties IN (
        'AdministrativeDuties', -- Administrative duties
        'CombatAndMissions', -- Combat and missions
        'LogisticsAndSupplyChainManagement', -- Logistics and supply chain management
        'MaintenanceAndRepairs', -- Maintenance and repairs
        'OperationsAndTraining', -- Operations and training
        'Unknown', -- Unknown
        'Other' -- Other
    )),
    MilitaryExpertise TEXT CHECK (MilitaryExpertise IN (
        'CommunicationSkills', -- Communication skills
        'CulturalAwareness', -- Cultural awareness
        'LeadershipAndManagement', -- Leadership and management
        'LogisticsAndMaintenance', -- Logistics and maintenance
        'SecurityAndSafety', -- Security and safety
        'TechnicalSkills', -- Technical skills
        'Unknown' -- Unknown
    )),
    MilitaryHighestRank TEXT, -- Highest rank achieved
    MilitaryHonors TEXT, -- Military honors received
    MilitaryInductionDate DATE, -- Date inducted into service
    MilitaryInductionRank TEXT, -- Rank at induction
    MilitaryOccupationalSpecialties TEXT, -- MOS code, see VA crosswalk
    MilitaryReleaseDate DATE, -- Date released from active service
    MilitaryServiceLocations TEXT, -- Duty stations during service
    MilitaryServiceNumber TEXT, -- Military service identifier
    MilitaryVeteranStatusIndicator TEXT CHECK (MilitaryVeteranStatusIndicator IN (
        'NotVeteran', -- Not a Veteran
        'Veteran', -- Veteran
        'Unknown' -- Unknown
    )),
    NationalGuardIndicator TEXT CHECK (NationalGuardIndicator IN ('Yes', 'No', 'Unknown')),
    DentalInsuranceCoverageType TEXT CHECK (DentalInsuranceCoverageType IN (
        'NonWorkplace', -- Non-workplace or personal
        'Workplace', -- Workplace
        'Medicaid', -- Medicaid
        'StateOnlyFunded', -- State-only funded insurance
        'SSI', -- Supplemental security income
        'Military', -- Military medical
        'Veteran', -- Veteran's medical
        'None', -- None
        'Other' -- Other
    )),
    InsuranceCoverage TEXT CHECK (InsuranceCoverage IN (
        'NonWorkplace', -- Non-workplace or personal
        'Workplace', -- Workplace
        'Medicaid', -- Medicaid
        'StateOnlyFunded', -- State-only funded insurance
        'SSI', -- Supplemental security income
        'Military', -- Military medical
        'Veteran', -- Veteran's medical
        'None', -- None
        'Other' -- Other
    )),
    PublicAssistanceStatus TEXT CHECK (PublicAssistanceStatus IN ('Yes', 'No')),
    ISO6392LanguageCode TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    ISO6393LanguageCode TEXT, -- ISO 639-3 language code, see http://www-01.sil.org/iso639-3/default.asp
    ISO6395LanguageFamily TEXT CHECK (ISO6395LanguageFamily IN (
        'aav', -- Austro-Asiatic languages
        'afa', -- Afro-Asiatic languages
        'alg', -- Algonquian languages
        'alv', -- Atlantic-Congo languages
        'apa', -- Apache languages
        'aqa', -- Alacalufan languages
        'aql', -- Algic languages
        'art', -- Artificial languages
        'ath', -- Athapascan languages
        'auf', -- Arauan languages
        'aus', -- Australian languages
        'awd', -- Arawakan languages
        'azc', -- Uto-Aztecan languages
        'bad', -- Banda languages
        'bai', -- Bamileke languages
        'bat', -- Baltic languages
        'ber', -- Berber languages
        'bih', -- Bihari languages
        'bnt', -- Bantu languages
        'btk', -- Batak languages
        'cai', -- Central American Indian languages
        'cau', -- Caucasian languages
        'cba', -- Chibchan languages
        'ccn', -- North Caucasian languages
        'ccs', -- South Caucasian languages
        'cdc', -- Chadic languages
        'cdd', -- Caddoan languages
        'cel', -- Celtic languages
        'cmc', -- Chamic languages
        'cpe', -- Creoles and pidgins, English-based
        'cpf', -- Creoles and pidgins, French-based
        'cpp', -- Creoles and pidgins, Portuguese-based
        'crp', -- Creoles and pidgins
        'csu', -- Central Sudanic languages
        'cus', -- Cushitic languages
        'day', -- Land Dayak languages
        'dmn', -- Mande languages
        'dra', -- Dravidian languages
        'egx', -- Egyptian languages
        'esx', -- Eskimo-Aleut languages
        'euq', -- Basque (family)
        'fiu', -- Finno-Ugrian languages
        'fox', -- Formosan languages
        'gem', -- Germanic languages
        'gme', -- East Germanic languages
        'gmq', -- North Germanic languages
        'gmw', -- West Germanic languages
        'grk', -- Greek languages
        'hmx', -- Hmong-Mien languages
        'hok', -- Hokan languages
        'hyx', -- Armenian (family)
        'iir', -- Indo-Iranian languages
        'ijo', -- Ijo languages
        'inc', -- Indic languages
        'ine', -- Indo-European languages
        'ira', -- Iranian languages
        'iro', -- Iroquoian languages
        'itc', -- Italic languages
        'jpx', -- Japanese (family)
        'kar', -- Karen languages
        'kdo', -- Kordofanian languages
        'khi', -- Khoisan languages
        'kro', -- Kru languages
        'map', -- Austronesian languages
        'mkh', -- Mon-Khmer languages
        'mno', -- Manobo languages
        'mun', -- Munda languages
        'myn', -- Mayan languages
        'nah', -- Nahuatl languages
        'nai', -- North American Indian languages
        'ngf', -- Trans-New Guinea languages
        'nic', -- Niger-Kordofanian languages
        'nub', -- Nubian languages
        'omq', -- Oto-Manguean languages
        'omv', -- Omotic languages
        'oto', -- Otomian languages
        'paa', -- Papuan languages
        'phi', -- Philippine languages
        'plf', -- Central Malayo-Polynesian languages
        'poz', -- Malayo-Polynesian languages
        'pqe', -- Eastern Malayo-Polynesian languages
        'pqw', -- Western Malayo-Polynesian languages
        'pra', -- Prakrit languages
        'qwe', -- Quechuan (family)
        'roa', -- Romance languages
        'sai', -- South American Indian languages
        'sal', -- Salishan languages
        'sdv', -- Eastern Sudanic languages
        'sem', -- Semitic languages
        'sgn', -- Sign languages
        'sio', -- Siouan languages
        'sit', -- Sino-Tibetan languages
        'sla', -- Slavic languages
        'smi', -- Sami languages
        'son', -- Songhai languages
        'sqj', -- Albanian languages
        'ssa', -- Nilo-Saharan languages
        'syd', -- Samoyedic languages
        'tai', -- Tai languages
        'tbq', -- Tibeto-Burman languages
        'trk', -- Turkic languages
        'tup', -- Tupi languages
        'tut', -- Altaic languages
        'tuw', -- Tungus languages
        'urj', -- Uralic languages
        'wak', -- Wakashan languages
        'wen', -- Sorbian languages
        'xgn', -- Mongolian languages
        'xnd', -- Na-Dene languages
        'ypk', -- Yupik languages
        'zhx', -- Chinese (family)
        'zle', -- East Slavic languages
        'zls', -- South Slavic languages
        'zlw', -- West Slavic languages
        'znd' -- Zande languages
    )),
    LanguageType TEXT CHECK (LanguageType IN (
        'Correspondence', -- Correspondence
        'Dominant', -- Dominant language
        'Home', -- Home language
        'Native', -- Native language
        'OtherLanguageProficiency', -- Other language proficiency
        'Other', -- Other
        'Spoken', -- Spoken Correspondence
        'Written' -- Written Correspondence
    ))
);

-- Creating table for Parent/Guardian entity
CREATE TABLE ParentGuardian (
    PersonIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    PersonIdentificationSystem TEXT CHECK (PersonIdentificationSystem IN (
        'SSN', -- Social Security Administration number
        'USVisa', -- US government Visa number
        'PIN', -- Personal identification number
        'Federal', -- Federal identification number
        'DriversLicense', -- Driver's license number
        'Medicaid', -- Medicaid number
        'HealthRecord', -- Health record number
        'ProfessionalCertificate', -- Professional certificate or license number
        'School', -- School-assigned number
        'District', -- District-assigned number
        'State', -- State-assigned number
        'Institution', -- Institution-assigned number
        'OtherFederal', -- Other federally assigned number
        'SelectiveService', -- Selective Service Number
        'CanadianSIN', -- Canadian Social Insurance Number
        'BirthCertificate', -- Birth certificate number
        'Other' -- Other
    )),
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    OtherFirstName TEXT, -- Alternate first name
    OtherMiddleName TEXT, -- Alternate middle name
    OtherLastName TEXT, -- Alternate last name
    OtherName TEXT, -- Previous or alternate names
    OtherNameType TEXT CHECK (OtherNameType IN (
        'Alias', -- Alias
        'Nickname', -- Nickname
        'OtherName', -- Other name
        'PreviousLegalName', -- Previous legal name
        'PreferredFamilyName', -- Preferred Family Name
        'PreferredGivenName', -- Preferred Given Name
        'FullName' -- Full Name
    )),
    PersonalInformationType TEXT CHECK (PersonalInformationType IN (
        'Address', -- Address
        'Birthdate', -- Birthdate
        'Name', -- Name
        'TelephoneNumber' -- Telephone Number
    )),
    PersonalInformationVerification TEXT CHECK (PersonalInformationVerification IN (
        '01003', -- Baptismal or church certificate
        '01004', -- Birth certificate
        '01012', -- Driver's license
        '01005', -- Entry in family Bible
        '01006', -- Hospital certificate
        '01013', -- Immigration document/visa
        '02382', -- Life insurance policy
        '09999', -- Other
        '03424', -- Other non-official document
        '03423', -- Other official document
        '01007', -- Parent's affidavit
        '01008', -- Passport
        '01009', -- Physician's certificate
        '01010', -- Previously verified school records
        '01011', -- State-issued ID
        '73095', -- Approved Transfer
        '73102', -- Birth Registration Form
        '73097', -- Citizenship Card
        '73100', -- Lease Agreement
        '73093', -- Non-Parent Affidavit of Residence
        '73094', -- Parent's Affidavit of Residence
        '73101', -- Purchase Agreement
        '73092', -- Residence Verification Form
        '73098', -- Tax Bill
        '73091', -- Telephone Bill
        '73099', -- Utility Bill
        '73096' -- Water Bill
    )),
    CustodialParentOrGuardianIndicator TEXT CHECK (CustodialParentOrGuardianIndicator IN ('Yes', 'No', 'Unknown')),
    EmergencyContactIndicator TEXT CHECK (EmergencyContactIndicator IN ('Yes', 'No')),
    IncludedInCountedFamilySize TEXT CHECK (IncludedInCountedFamilySize IN ('Yes', 'No')),
    PersonRelationshipToLearnerContactPriorityNumber INTEGER, -- Contact priority order
    PersonRelationshipToLearnerContactRestrictionsDescription TEXT, -- Contact restrictions
    PersonRelationshipToLearnerLivesWithIndicator TEXT CHECK (PersonRelationshipToLearnerLivesWithIndicator IN ('Yes', 'No')),
    PersonRelationshipType TEXT CHECK (PersonRelationshipType IN (
        'Aunt', -- Aunt
        'Brother', -- Brother
        'BrotherInLaw', -- Brother-in-law
        'CourtAppointedGuardian', -- Court appointed guardian
        'Daughter', -- Daughter
        'DaughterInLaw', -- Daughter-in-law
        'Employer', -- Employer
        'Father', -- Father
        'FathersSignificantOther', -- Father's significant other
        'FathersCivilPartner', -- Father's civil partner
        'FatherInLaw', -- Father-in-law
        'Fiance', -- Fiance
        'Fiancee', -- Fiancee
        'Friend', -- Friend
        'Grandfather', -- Grandfather
        'Grandmother', -- Grandmother
        'Husband', -- Husband
        'MothersSignificantOther', -- Mother's significant other
        'Mother', -- Mother
        'MothersCivilPartner', -- Mother's civil partner
        'Nephew', -- Nephew
        'Niece', -- Niece
        'Other', -- Other
        'SignificantOther', -- Significant other
        'Sister', -- Sister
        'Son', -- Son
        'Unknown', -- Unknown
        'Uncle', -- Uncle
        'Ward', -- Ward
        'Wife', -- Wife
        'AdoptedDaughter', -- Adopted Daughter
        'AdoptedSon', -- Adopted son
        'AdoptiveParent', -- Adoptive parent
        'Advisor', -- Advisor
        'AgencyRepresentative', -- Agency representative
        'Cousin', -- Cousin
        'Dependent', -- Dependent
        'FamilyMember', -- Family member
        'FormerHusband', -- Former husband
        'FormerWife', -- Former wife
        'FosterDaughter', -- Foster daughter
        'FosterFather', -- Foster father
        'FosterMother', -- Foster mother
        'FosterParent', -- Foster Parent
        'FosterSon', -- Foster son
        'Godparent', -- Godparent
        'Granddaughter', -- Granddaughter
        'Grandparent', -- Grandparent
        'Grandson', -- Grandson
        'GreatAunt', -- Great aunt
        'GreatGrandparent', -- Great grandparent
        'GreatUncle', -- Great uncle
        'HalfBrother', -- Half-brother
        'HalfSister', -- Half-sister
        'LifePartner', -- Life partner
        'LifePartnerOfParent', -- Life partner of parent
        'MotherInLaw', -- Mother-in-law
        'Neighbor', -- Neighbor
        'Parent', -- Parent
        'Partner', -- Partner
        'PartnerOfParent', -- Partner of parent
        'ProbationOfficer', -- Probation officer
        'Relative', -- Relative
        'Sibling', -- Sibling
        'SisterInLaw', -- Sister-in-law
        'SonInLaw', -- Son-in-law
        'Spouse', -- Spouse
        'Stepbrother', -- Stepbrother
        'Stepdaughter', -- Stepdaughter
        'Stepfather', -- Stepfather
        'Stepmother', -- Stepmother
        'Stepparent', -- Stepparent
        'Stepsister', -- Stepsister
        'Stepson' -- Stepson
    )),
    PrimaryContactIndicator TEXT CHECK (PrimaryContactIndicator IN ('Yes', 'No')),
    ChildIdentifier TEXT, -- References EarlyLearningChild table
    StudentIdentifier TEXT, -- Unique student identifier, follows XSD:Token format
    StudentIdentificationSystem TEXT CHECK (StudentIdentificationSystem IN (
        'CanadianSIN', -- Canadian Social Insurance Number
        'District', -- District-assigned number
        'Family', -- Family unit number
        'Federal', -- Federal identification number
        'NationalMigrant', -- National migrant number
        'School', -- School-assigned number
        'SSN', -- Social Security Administration number
        'State', -- State-assigned number
        'StateMigrant', -- State migrant number
        'BirthCertificate' -- Birth certificate number
    ))
);

-- Creating table for Early Learning Development Observation entity
CREATE TABLE EarlyLearningDevelopmentObservation (
    ChildIdentifier TEXT NOT NULL, -- References EarlyLearningChild table
    ObservationDate DATE, -- Date of observation
    ObservationEventDescription TEXT, -- Description of observation event
    ObservationEventType TEXT CHECK (ObservationEventType IN (
        'Health', -- Health
        'Safety', -- Safety
        'Nutrition', -- Nutrition
        'Behavior', -- Behavior
        'Other' -- Other
    ))
);

-- Creating table for Program entity
CREATE TABLE Program (
    ProgramName TEXT, -- Name of the program
    ProgramType TEXT CHECK (ProgramType IN (
        '73056', -- Adult Basic Education
        '73058', -- Adult English as a Second Language
        '73057', -- Adult Secondary Education
        '04961', -- Alternative Education
        '04932', -- Athletics
        '04923', -- Bilingual education program
        '04906', -- Career and Technical Education
        '04931', -- Cocurricular programs
        '04958', -- College preparatory
        '04945', -- Community service program
        '04944', -- Community/junior college education program
        '04922', -- Compensatory services
        '73059', -- Continuing Education
        '04956', -- Counseling services
        '14609', -- Early Head Start
        '04928', -- English as a second language program
        '04919', -- Even Start
        '04955', -- Extended day/child care services
        '75000', -- Foster Care
        '04930', -- Gifted and talented program
        '04918', -- Head start
        '04963', -- Health Services Program
        '04957', -- Immigrant education
        '04921', -- Indian education
        '04959', -- International Baccalaureate
        '04962', -- Library/Media Services Program
        '04960', -- Magnet/Special Program Emphasis
        '04920', -- Migrant education
        '04887', -- Regular education
        '04964', -- Remedial education
        '04967', -- Section 504 Placement
        '04966', -- Service learning
        '04888', -- Special Education Services
        '04954', -- Student retention/Dropout Prevention
        '04953', -- Substance abuse education/prevention
        '73204', -- Targeted intervention program
        '04968', -- Teacher professional development
        '04917', -- Technical preparatory
        '75001', -- Title I
        '73090', -- Work-based Learning Opportunities
        '75014', -- Autism program
        '75015', -- Early childhood special education tier one
        '09999', -- Other
        '75016', -- Early childhood special education tier two
        '75002', -- Early College
        '75006', -- Emotional disturbance program
        '75008', -- Hearing impairment program
        '75017', -- K12 Resource Program
        '75003', -- Mild cognitive disability program
        '75004', -- Moderate cognitive disability program
        '75012', -- Multiple disabilities program
        '75011', -- Orthopedic impairment
        '75010', -- Other health impairment
        '75005', -- Significant cognitive disability program
        '75007', -- Specific learning disability program
        '75013', -- Speech or language impairment program
        '75009', -- Visual impairment program
        '75018', -- Hospital
        '76000', -- McKinney-Vento Homeless
        '77000', -- Title III LIEP
        '75019', -- Neglected or delinquent
        '75020' -- TANF
    ))
);

-- Creating table for Early Childhood Program entity
CREATE TABLE EarlyChildhoodProgram (
    ProgramName TEXT, -- References Program table
    EarlyChildhoodProgramType TEXT CHECK (EarlyChildhoodProgramType IN (
        'HeadStart', -- Head Start
        'EarlyHeadStart', -- Early Head Start
        'StateFunded', -- State-funded prekindergarten
        'Private', -- Private preschool
        'Public', -- Public preschool
        'HomeBased', -- Home-based early childhood program
        'Other' -- Other
    ))
);

-- Creating table for Early Childhood Class Group entity
CREATE TABLE EarlyChildhoodClassGroup (
    ClassGroupIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    ClassGroupType TEXT CHECK (ClassGroupType IN (
        'Home', -- Homeroom
        'Scheduled', -- Scheduled class
        'SelfContained', -- Self-contained class
        'Other' -- Other
    )),
    EarlyChildhoodClassType TEXT CHECK (EarlyChildhoodClassType IN (
        'InfantToddler', -- Infant/Toddler
        'Preschool', -- Preschool
        'Prekindergarten', -- Prekindergarten
        'TransitionalKindergarten', -- Transitional Kindergarten
        'Other' -- Other
    ))
);

-- Career and Technical (CTE)
-- Creating table for Course entity
CREATE TABLE CTECourse (
    CourseIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    CourseTitle TEXT NOT NULL, -- Descriptive name of the course
    CourseDescription TEXT, -- Description of course content/goals
    CourseDepartmentName TEXT, -- Department with jurisdiction
    CourseCodeSystem TEXT CHECK (CourseCodeSystem IN (
        'Intermediate', -- Intermediate agency course code
        'LEA', -- LEA course code
        'NCES', -- NCES Pilot Standard National Course Classification System
        'Other', -- Other
        'SCED', -- School Codes for the Exchange of Data (SCED) course code
        'School', -- School course code
        'State', -- State course code
        'University' -- University course code
    )),
    CourseCreditUnits TEXT CHECK (CourseCreditUnits IN (
        'NoCredit', -- No Credit
        'Quarter', -- Quarter
        'Semester', -- Semester
        'Units', -- Units
        'CarnegieUnits', -- Carnegie Units
        'ContinuingEducationUnits', -- Continuing Education Units
        'ClockHours', -- Clock Hours
        'Other', -- Other
        'Unreported' -- Unreported
    )),
    CreditValue REAL, -- Amount of credit available
    CreditUnitType TEXT CHECK (CreditUnitType IN (
        '00585', -- Carnegie unit
        '00586', -- Semester hour credit
        '00587', -- Trimester hour credit
        '00588', -- Quarter hour credit
        '00589', -- Quinmester hour credit
        '00590', -- Mini-term hour credit
        '00591', -- Summer term hour credit
        '00592', -- Intersession hour credit
        '00595', -- Long session hour credit
        '00596', -- Twelve month hour credit
        '00597', -- Career and Technical Education credit
        '73062', -- Adult high school credit
        '00599', -- Credit by examination
        '00600', -- Correspondence credit
        '00601', -- Converted occupational experience credit
        '09999', -- Other
        '75001', -- Certificate credit
        '75002', -- Degree credit
        '75003', -- Continuing education credit
        '75004' -- Professional development hours
    )),
    AvailableCarnegieUnitCredit REAL, -- Carnegie units offered
    CourseGPAApplicability TEXT CHECK (CourseGPAApplicability IN (
        'Applicable', -- Applicable in GPA
        'NotApplicable', -- Not Applicable in GPA
        'Weighted' -- Weighted in GPA
    )),
    CourseLevelCharacteristic TEXT CHECK (CourseLevelCharacteristic IN (
        '00568', -- Remedial course
        '00569', -- Students with disabilities course
        '00570', -- Basic course
        '00571', -- General course
        '00572', -- Honors level course
        '00573', -- Gifted and talented course
        '00574', -- International Baccalaureate course
        '00575', -- Advanced placement course
        '00576', -- College-level course
        '00577', -- Untracked course
        '00578', -- English Learner course
        '00579', -- Accepted as a high school equivalent
        '73044', -- Career and technical education general course
        '00741', -- Completion of requirement, no units awarded
        '73045', -- Career and technical education dual-credit course
        '73048', -- Dual enrollment
        '73047', -- Not applicable
        '73046', -- Pre-advanced placement
        '73049' -- Other
    )),
    CourseLevelApprovalIndicator TEXT CHECK (CourseLevelApprovalIndicator IN ('Yes', 'No')),
    CourseRepeatabilityMaximumNumber INTEGER, -- Max times course can be taken for credit
    AdditionalCreditType TEXT CHECK (AdditionalCreditType IN (
        'AdvancedPlacement', -- Advanced Placement
        'ApprenticeshipCredit', -- Apprenticeship Credit
        'CTE', -- Career and Technical Education
        'DualCredit', -- Dual Credit
        'InternationalBaccalaureate', -- International Baccalaureate
        'Other', -- Other
        'QualifiedAdmission', -- Qualified Admission
        'STEM', -- Science, Technology, Engineering and Mathematics
        'CTEAndAcademic', -- Simultaneous CTE and Academic Credit
        'StateScholarship' -- State Scholarship
    )),
    CurriculumFrameworkType TEXT CHECK (CurriculumFrameworkType IN (
        'LEA', -- Local Education Agency curriculum framework
        'NationalStandard', -- National curriculum standard
        'PrivateOrReligious', -- Private, religious curriculum
        'School', -- School curriculum framework
        'State', -- State curriculum framework
        'Other' -- Other
    )),
    HighSchoolCourseRequirement TEXT CHECK (HighSchoolCourseRequirement IN ('Yes', 'No')),
    InstructionLanguage TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    SCEDCourseCode TEXT, -- Five-digit SCED code, see https://nces.ed.gov/forum/SCED.asp
    SCEDCourseLevel TEXT CHECK (SCEDCourseLevel IN (
        'B', -- Basic or remedial
        'E', -- Enriched or advanced
        'G', -- General or regular
        'H', -- Honors
        'C', -- College
        'X' -- No specified level of rigor
    )),
    SCEDCourseSubjectArea TEXT CHECK (SCEDCourseSubjectArea IN (
        '01', -- English Language and Literature
        '02', -- Mathematics
        '03', -- Life and Physical Sciences
        '04', -- Social Sciences and History
        '05', -- Visual and Performing Arts
        '07', -- Religious Education and Theology
        '08', -- Physical, Health, and Safety Education
        '09', -- Military Science
        '10', -- Information Technology
        '11', -- Communication and Audio/Visual Technology
        '12', -- Business and Marketing
        '13', -- Manufacturing
        '14', -- Health Care Sciences
        '15', -- Public, Protective, and Government Service
        '16', -- Hospitality and Tourism
        '17', -- Architecture and Construction
        '18', -- Agriculture, Food, and Natural Resources
        '19', -- Human Services
        '20', -- Transportation, Distribution and Logistics
        '21', -- Engineering and Technology
        '22', -- Miscellaneous
        '23', -- Non-Subject-Specific
        '24' -- World Languages
    )),
    SCEDSequenceOfCourse TEXT, -- Sequence as 'n of m' parts
    CoreAcademicCourse TEXT CHECK (CoreAcademicCourse IN ('Yes', 'No')),
    CourseAlignedWithStandards TEXT CHECK (CourseAlignedWithStandards IN ('Yes', 'No'))
);

-- Creating table for Course Section entity
CREATE TABLE CTECourseSection (
    CourseSectionIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    CourseIdentifier TEXT, -- References Course table
    AgencyCourseIdentifier TEXT, -- Regional/state identifier, follows XSD:Token
    CourseBeginDate DATE, -- Start date of course instance
    CourseEndDate DATE, -- End date of course instance
    CourseNumber TEXT, -- Official reference number
    CourseSectionNumber TEXT, -- Differentiates course occurrences
    ClassroomIdentifier TEXT, -- Unique room identifier, follows XSD:Token
    ClassBeginningTime TEXT, -- Time class begins
    ClassEndingTime TEXT, -- Time class ends
    ClassMeetingDays TEXT, -- Days class meets
    ClassPeriod TEXT, -- Session portion for instruction
    SessionCode TEXT, -- Local code for term
    SessionDescription TEXT, -- Short session description
    SessionDesignator TEXT, -- Academic session identifier
    SessionBeginDate DATE, -- Session start date
    SessionEndDate DATE, -- Session end date
    SessionSequenceNumber INTEGER, -- Position in sequence of sessions
    SessionType TEXT CHECK (SessionType IN (
        'FullSchoolYear', -- Full School Year
        'Intersession', -- Intersession
        'LongSession', -- Long Session
        'MiniTerm', -- Mini Term
        'Quarter', -- Quarter
        'Quinmester', -- Quinmester
        'Semester', -- Semester
        'SummerTerm', -- Summer Term
        'Trimester', -- Trimester
        'TwelveMonth', -- Twelve Month
        'Other' -- Other
    )),
    SessionAttendanceTermIndicator TEXT CHECK (SessionAttendanceTermIndicator IN ('Yes', 'No')),
    SessionMarkingTermIndicator TEXT CHECK (SessionMarkingTermIndicator IN ('Yes', 'No')),
    SessionSchedulingTermIndicator TEXT CHECK (SessionSchedulingTermIndicator IN ('Yes', 'No')),
    TimetableDayIdentifier TEXT, -- Rotation cycle identifier, follows XSD:Token
    CourseSectionMaximumCapacity INTEGER, -- Max number of students
    CourseSectionTimeRequiredForCompletion INTEGER, -- Clock minutes for completion
    CourseAcademicGradeScaleCode TEXT, -- AMCAS grade scale (01-99)
    OriginalCourseIdentifier TEXT, -- Previous course identifier, follows XSD:Token
    OverrideSchoolCourseNumber TEXT, -- How course was identified
    AdditionalCreditType TEXT CHECK (AdditionalCreditType IN (
        'AdvancedPlacement', -- Advanced Placement
        'ApprenticeshipCredit', -- Apprenticeship Credit
        'CTE', -- Career and Technical Education
        'DualCredit', -- Dual Credit
        'InternationalBaccalaureate', -- International Baccalaureate
        'Other', -- Other
        'QualifiedAdmission', -- Qualified Admission
        'STEM', -- Science, Technology, Engineering and Mathematics
        'CTEAndAcademic', -- Simultaneous CTE and Academic Credit
        'StateScholarship' -- State Scholarship
    )),
    AdvancedPlacementCourseCode TEXT CHECK (AdvancedPlacementCourseCode IN (
        'ArtHistory', -- Art History
        'Biology', -- Biology
        'CalculusAB', -- Calculus AB
        'CalculusBC', -- Calculus BC
        'Chemistry', -- Chemistry
        'ComputerScienceA', -- Computer Science A
        'ComputerScienceAB', -- Computer Science AB
        'Macroeconomics', -- Macroeconomics
        'Microeconomics', -- Microeconomics
        'EnglishLanguage', -- English Language
        'EnglishLiterature', -- English Literature
        'EnvironmentalScience', -- Environmental Science
        'EuropeanHistory', -- European History
        'FrenchLanguage', -- French Language
        'FrenchLiterature', -- French Literature
        'GermanLanguage', -- German Language
        'CompGovernmentAndPolitics', -- Comp Government And Politics
        'USGovernmentAndPolitics', -- US Government And Politics
        'HumanGeography', -- Human Geography
        'ItalianLanguageAndCulture', -- Italian Language And Culture
        'LatinLiterature', -- Latin Literature
        'LatinVergil', -- Latin Vergil
        'MusicTheory', -- Music Theory
        'PhysicsB', -- Physics B
        'PhysicsC', -- Physics C
        'Psychology', -- Psychology
        'SpanishLanguage', -- Spanish Language
        'SpanishLiterature', -- Spanish Literature
        'Statistics', -- Statistics
        'StudioArt', -- Studio Art
        'USHistory', -- US History
        'WorldHistory' -- World History
    )),
    BlendedLearningModelType TEXT CHECK (BlendedLearningModelType IN (
        'Rotation', -- Rotation model
        'FlexModel', -- Flex model
        'ALaCarte', -- A La Carte model
        'EnrichedVirtual', -- Enriched Virtual model
        'Other' -- Other
    )),
    CareerCluster TEXT CHECK (CareerCluster IN (
        '01', -- Agriculture, Food & Natural Resources
        '02', -- Architecture & Construction
        '03', -- Arts, A/V Technology & Communications
        '04', -- Business Management & Administration
        '05', -- Education & Training
        '06', -- Finance
        '07', -- Government & Public Administration
        '08', -- Health Science
        '09', -- Hospitality & Tourism
        '10', -- Human Services
        '11', -- Information Technology
        '12', -- Law, Public Safety, Corrections & Security
        '13', -- Manufacturing
        '14', -- Marketing
        '15', -- Science, Technology, Engineering & Mathematics
        '16' -- Transportation, Distribution & Logistics
    )),
    ClassroomPositionType TEXT CHECK (ClassroomPositionType IN (
        '03187', -- Administrative staff
        '73071', -- Co-teacher
        '04725', -- Counselor
        '73073', -- Course Proctor
        '05973', -- Instructor of record
        '01234', -- Intern
        '73072', -- Lead Team Teacher
        '00069', -- Non-instructional staff
        '09999', -- Other
        '00059', -- Paraprofessionals/teacher aides
        '05971', -- Primary instructor
        '04735', -- Resource teacher
        '05972', -- Secondary instructor
        '73074', -- Special Education Consultant
        '00080', -- Student teachers
        '01382' -- Volunteer/no contract
    )),
    CourseAlignedWithStandards TEXT CHECK (CourseAlignedWithStandards IN ('Yes', 'No')),
    CourseApplicableEducationLevel TEXT CHECK (CourseApplicableEducationLevel IN (
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'AS', -- Associate's degree
        'BA', -- Bachelor's degree
        'PB', -- Post-baccalaureate certificate
        'MD', -- Master's degree
        'PM', -- Post-master's certificate
        'DO', -- Doctoral degree
        'PD', -- Post-doctoral certificate
        'AE', -- Adult Education
        'PT', -- Professional or technical credential
        'OT' -- Other
    )),
    CourseCertificationDescription TEXT, -- Certification associated with course
    CourseCreditBasisType TEXT CHECK (CourseCreditBasisType IN (
        'Regular', -- Regular/general enrollment
        'Major', -- Credit associated with student's major
        'AcademicRenewal', -- Academic Renewal
        'AdultBasic', -- Adult Basic
        'AdvancedPlacement', -- Advanced Placement
        'AdvancedStanding', -- Advanced Standing
        'Correspondence', -- Correspondence
        'ContinuingEducation', -- Continuing Education
        'Exemption', -- Exemption
        'Equivalence', -- Equivalence
        'InternationalBaccalaureate', -- International Baccalaureate
        'Military', -- Military
        'Remedial', -- Remedial/developmental
        'CreditByExam', -- Credit from standardized test
        'HighSchoolTransferCredit', -- High school credit transferred to college
        'HighSchoolCreditOnly', -- College credit transferred to high school
        'HighSchoolDualCredit', -- Credit counted at both college and high school
        'JuniorHighSchoolCredit' -- Junior high credit counted at high school
    )),
    CourseCreditLevelType TEXT CHECK (CourseCreditLevelType IN (
        'Undergraduate', -- Undergraduate
        'Ungraded', -- Ungraded
        'LowerDivision', -- Lower division credit
        'UpperDivision', -- Higher or upper division credit
        'Vocational', -- Vocational/technical credit
        'TechnicalPreparatory', -- Technical preparatory credit
        'Graduate', -- Graduate level credit
        'Professional', -- Professional
        'Dual', -- Dual Level
        'GraduateProfessional' -- Graduate Professional
    )),
    CourseFundingProgram TEXT, -- Funding program for course
    CourseGPAApplicability TEXT CHECK (CourseGPAApplicability IN (
        'Applicable', -- Applicable in GPA
        'NotApplicable', -- Not Applicable in GPA
        'Weighted' -- Weighted in GPA
    )),
    CourseHonorsType TEXT CHECK (CourseHonorsType IN (
        'Honors', -- Honors
        'HonorsOption' -- Honors option
    )),
    CourseInstructionMethod TEXT CHECK (CourseInstructionMethod IN (
        'Lecture', -- Lecture
        'Laboratory', -- Laboratory
        'Seminar', -- Seminar
        'IndependentStudy', -- Independent Study
        'PrivateStudy', -- Private Study
        'PracticeTeaching', -- Practice Teaching
        'Internship', -- Internship
        'Practicum', -- Practicum
        'ApprenticeshipExternship', -- Apprenticeship Externship
        'AppliedInstruction', -- Applied Instruction
        'Residency', -- Residency
        'ClinicalRotationInstruction', -- Clinical Rotation Instruction
        'SelfPaced', -- Self Paced
        'FieldStudy', -- Field Study
        'InternetInstruction', -- Internet Instruction
        'InteractiveVideo', -- Interactive Video
        'Videotape', -- Videotape
        'Television', -- Television
        'OtherDistanceLearning', -- Other Distance Learning
        'Audiotape', -- Audiotape
        'ComputerBasedInstruction', -- Computer Based Instruction
        'CompressedVideo', -- Compressed Video
        'Correspondence', -- Correspondence
        'CooperativeEducation', -- Cooperative Education
        'WorkStudy' -- Work Study
    )),
    CourseInstructionSiteName TEXT, -- Location name where course is taught
    CourseInstructionSiteType TEXT CHECK (CourseInstructionSiteType IN (
        'OnCampus', -- On campus
        'OffCampus', -- Off campus (e.g., branch campus)
        'Extension', -- Extension center or site
        'StudyAbroad', -- Study abroad
        'Correctional', -- Correctional institution
        'Military', -- Military Base
        'Telecommunication', -- Instructional telecommunications
        'Auxiliary', -- Auxiliary
        'ClinicHospital' -- Clinic or hospital
    )),
    CourseInteractionMode TEXT CHECK (CourseInteractionMode IN (
        'Asynchronous', -- Asynchronous
        'Synchronous' -- Synchronous
    )),
    CourseLevelType TEXT CHECK (CourseLevelType IN (
        'Accelerated', -- Accelerated
        'AdultBasic', -- Adult Basic
        'AdvancedPlacement', -- Advanced Placement
        'Basic', -- Basic
        'InternationalBaccalaureate', -- International Baccalaureate
        'CollegeLevel', -- College Level
        'CollegePreparatory', -- College Preparatory
        'GiftedTalented', -- Gifted and Talented
        'Honors', -- Honors
        'NonAcademic', -- Non-Academic
        'SpecialEducation', -- Special Education
        'TechnicalPreparatory', -- Technical Preparatory
        'Vocational', -- Vocational
        'LowerDivision', -- Lower division
        'UpperDivision', -- Upper division
        'Dual', -- Dual level
        'GraduateProfessional', -- Graduate/Professional
        'Regents', -- Regents
        'Remedial', -- Remedial/Developmental
        'K12' -- K12
    )),
    CourseNarrativeExplanationGrade TEXT, -- Narrative for non-letter/numeric grade
    CourseRepeatCode TEXT CHECK (CourseRepeatCode IN (
        'RepeatCounted', -- Repeated, counted in GPA
        'RepeatNotCounted', -- Repeated, not counted in GPA
        'ReplacementCounted', -- Replacement counted
        'ReplacedNotCounted', -- Replacement not counted
        'RepeatOtherInstitution', -- Repeated, other institution
        'NotCountedOther' -- Other, not counted in GPA
    )),
    CourseSectionInstructionalDeliveryMode TEXT CHECK (CourseSectionInstructionalDeliveryMode IN (
        'Broadcast', -- Broadcast
        'Correspondence', -- Correspondence
        'EarlyCollege', -- Early College
        'AudioVideo', -- Interactive Audio/Video
        'Online', -- Online
        'IndependentStudy', -- Independent Study
        'FaceToFace', -- Face to Face
        'BlendedLearning' -- Blended Learning
    )),
    CourseSectionSingleSexClassStatus TEXT CHECK (CourseSectionSingleSexClassStatus IN (
        'MaleOnly', -- Male-only
        'FemaleOnly', -- Female-only
        'NotSingleSex' -- Not a single-sex class
    )),
    DevelopmentalEducationType TEXT CHECK (DevelopmentalEducationType IN (
        'DevelopmentalMath', -- Developmental Math
        'DevelopmentalEnglish', -- Developmental English
        'DevelopmentalReading', -- Developmental Reading
        'DevelopmentalEnglishReading', -- Developmental English/Reading
        'DevelopmentalOther' -- Developmental Other
    )),
    FamilyAndConsumerSciencesCourseIndicator TEXT CHECK (FamilyAndConsumerSciencesCourseIndicator IN ('Yes', 'No')),
    InstructionLanguage TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    NCAAEligibility TEXT CHECK (NCAAEligibility IN ('Yes', 'No')),
    ReceivingLocationOfInstruction TEXT CHECK (ReceivingLocationOfInstruction IN (
        '00997', -- Business
        '00752', -- Community facility
        '00753', -- Home of student
        '00754', -- Hospital
        '03018', -- Library/media center
        '03506', -- Mobile
        '09999', -- Other
        '00341', -- Other K-12 educational institution
        '00342', -- Postsecondary facility
        '00675' -- School
    )),
    TuitionFunded TEXT CHECK (TuitionFunded IN ('Yes', 'No')),
    VirtualIndicator TEXT CHECK (VirtualIndicator IN ('Yes', 'No')),
    WorkBasedLearningOpportunityType TEXT CHECK (WorkBasedLearningOpportunityType IN (
        'Apprenticeship', -- Apprenticeship
        'ClinicalWork', -- Clinical work experience
        'CooperativeEducation', -- Cooperative education
        'JobShadowing', -- Job shadowing
        'Mentorship', -- Mentorship
        'NonPaidInternship', -- Non-Paid Internship
        'OnTheJob', -- On-the-Job
        'PaidInternship', -- Paid internship
        'ServiceLearning', -- Service learning
        'SupervisedAgricultural', -- Supervised agricultural experience
        'UnpaidInternship', -- Unpaid internship
        'Entrepreneurship', -- Entrepreneurship
        'SchoolBasedEnterprise', -- School-Based Enterprise
        'SimulatedWorksite', -- Simulated Worksite
        'Other' -- Other
    )),
    AdjustedCapacity INTEGER, -- Max participants in program
    AdjustedCapacityReasonType TEXT CHECK (AdjustedCapacityReasonType IN (
        '100', -- COVID-19
        '999' -- Other
    )),
    CIPCode TEXT, -- Six-digit CIP code, see https://nces.ed.gov/ipeds/cipcode/browse.aspx?y=55
    CIPVersion TEXT CHECK (CIPVersion IN (
        'CIP1980', -- CIP 1980
        'CIP1985', -- CIP 1985
        'CIP1990', -- CIP 1990
        'CIP2000', -- CIP 2000
        'CIP2010', -- CIP 2010
        'CIP2020' -- CIP 2020
    ))
);

-- Creating table for Course Section Attendance entity
CREATE TABLE CTECourseSectionAttendance (
    CourseSectionIdentifier TEXT NOT NULL, -- References CourseSection table
    AttendanceEventDate DATE, -- Date of attendance event
    AttendanceEventType TEXT CHECK (AttendanceEventType IN (
        'DailyAttendance', -- Daily attendance
        'ClassSectionAttendance', -- Class/section attendance
        'ProgramAttendance', -- Program attendance
        'ExtracurricularAttendance' -- Extracurricular attendance
    )),
    AttendanceStatus TEXT CHECK (AttendanceStatus IN (
        'Present', -- Present
        'ExcusedAbsence', -- Excused Absence
        'UnexcusedAbsence', -- Unexcused Absence
        'Tardy', -- Tardy
        'EarlyDeparture' -- Early Departure
    )),
    AttendanceEventDurationDay REAL, -- Duration in days (e.g., 1.0 for whole day)
    AttendanceEventDurationHours REAL, -- Duration in hours
    AttendanceEventDurationMinutes INTEGER -- Duration in minutes
);

-- Creating table for CTE Student entity
CREATE TABLE CTEStudent (
    StudentIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    StudentIdentificationSystem TEXT CHECK (StudentIdentificationSystem IN (
        'CanadianSIN', -- Canadian Social Insurance Number
        'District', -- District-assigned number
        'Family', -- Family unit number
        'Federal', -- Federal identification number
        'NationalMigrant', -- National migrant number
        'School', -- School-assigned number
        'SSN', -- Social Security Administration number
        'State', -- State-assigned number
        'StateMigrant', -- State migrant number
        'BirthCertificate' -- Birth certificate number
    )),
    FirstName TEXT, -- Legal first name
    MiddleName TEXT, -- Legal middle name
    LastOrSurname TEXT, -- Legal last name
    GenerationCodeOrSuffix TEXT, -- Generation appendage (e.g., Jr., Sr.)
    PersonalTitleOrPrefix TEXT, -- Title or prefix (e.g., Mr., Dr.)
    OtherFirstName TEXT, -- Alternate first name
    OtherMiddleName TEXT, -- Alternate middle name
    OtherLastName TEXT, -- Alternate last name
    OtherName TEXT, -- Previous or alternate names
    OtherNameType TEXT CHECK (OtherNameType IN (
        'Alias', -- Alias
        'Nickname', -- Nickname
        'OtherName', -- Other name
        'PreviousLegalName', -- Previous legal name
        'PreferredFamilyName', -- Preferred Family Name
        'PreferredGivenName', -- Preferred Given Name
        'FullName' -- Full Name
    )),
    PersonalInformationType TEXT CHECK (PersonalInformationType IN (
        'Address', -- Address
        'Birthdate', -- Birthdate
        'Name', -- Name
        'TelephoneNumber' -- Telephone Number
    )),
    PersonalInformationVerification TEXT CHECK (PersonalInformationVerification IN (
        '01003', -- Baptismal or church certificate
        '01004', -- Birth certificate
        '01012', -- Driver's license
        '01005', -- Entry in family Bible
        '01006', -- Hospital certificate
        '01013', -- Immigration document/visa
        '02382', -- Life insurance policy
        '09999', -- Other
        '03424', -- Other non-official document
        '03423', -- Other official document
        '01007', -- Parent's affidavit
        '01008', -- Passport
        '01009', -- Physician's certificate
        '01010', -- Previously verified school records
        '01011', -- State-issued ID
        '73095', -- Approved Transfer
        '73102', -- Birth Registration Form
        '73097', -- Citizenship Card
        '73100', -- Lease Agreement
        '73093', -- Non-Parent Affidavit of Residence
        '73094', -- Parent's Affidavit of Residence
        '73101', -- Purchase Agreement
        '73092', -- Residence Verification Form
        '73098', -- Tax Bill
        '73091', -- Telephone Bill
        '73099', -- Utility Bill
        '73096' -- Water Bill
    )),
    Birthdate DATE, -- Date of birth
    Sex TEXT CHECK (Sex IN (
        'Male', -- Male
        'Female', -- Female
        'NotSelected' -- Not selected
    )),
    AmericanIndianOrAlaskaNative TEXT CHECK (AmericanIndianOrAlaskaNative IN ('Yes', 'No', 'NotSelected')),
    Asian TEXT CHECK (Asian IN ('Yes', 'No', 'NotSelected')),
    BlackOrAfricanAmerican TEXT CHECK (BlackOrAfricanAmerican IN ('Yes', 'No', 'NotSelected')),
    NativeHawaiianOrOtherPacificIslander TEXT CHECK (NativeHawaiianOrOtherPacificIslander IN ('Yes', 'No', 'NotSelected')),
    White TEXT CHECK (White IN ('Yes', 'No', 'NotSelected')),
    HispanicOrLatinoEthnicity TEXT CHECK (HispanicOrLatinoEthnicity IN ('Yes', 'No', 'NotSelected')),
    DemographicRaceTwoOrMoreRaces TEXT CHECK (DemographicRaceTwoOrMoreRaces IN ('Yes', 'No')),
    Race TEXT CHECK (Race IN (
        'AmericanIndianOrAlaskaNative', -- American Indian or Alaska Native
        'Asian', -- Asian
        'BlackOrAfricanAmerican', -- Black or African American
        'DemographicRaceTwoOrMoreRaces', -- Demographic Race Two or More Races
        'NativeHawaiianOrOtherPacificIslander', -- Native Hawaiian or Other Pacific Islander
        'RaceAndEthnicityUnknown', -- Race and Ethnicity Unknown
        'White' -- White
    )),
    FederalRaceAndEthnicityDeclined TEXT CHECK (FederalRaceAndEthnicityDeclined IN ('Yes', 'No')),
    FirstGenerationCollegeStudent TEXT CHECK (FirstGenerationCollegeStudent IN ('Yes', 'No', 'Unknown')),
    CountryOfBirthCode TEXT, -- ISO 3166 country code, see http://www.iso.org/iso/country_codes.htm
    StandardOccupationalClassification TEXT, -- BLS SOC code, see https://www.bls.gov/soc/2018/major_groups.htm
    TribalAffiliation TEXT, -- Native American tribal entity
    InternetDownloadSpeed REAL, -- Download speed in Mbps
    InternetUploadSpeed REAL, -- Upload speed in Mbps
    InternetSpeedTestDateTime TEXT, -- Date and time of speed test
    AwaitingInitialIDEAEvaluationStatus TEXT CHECK (AwaitingInitialIDEAEvaluationStatus IN ('Yes', 'No')),
    DisabilityStatus TEXT CHECK (DisabilityStatus IN ('Yes', 'No')),
    IDEAIndicator TEXT CHECK (IDEAIndicator IN ('Yes', 'No')),
    Section504Status TEXT CHECK (Section504Status IN ('Yes', 'No')),
    PrimaryDisabilityType TEXT CHECK (PrimaryDisabilityType IN (
        'AUT', -- Autism
        'DB', -- Deaf-blindness
        'DD', -- Developmental delay
        'EMN', -- Emotional disturbance
        'HI', -- Hearing impairment
        'ID', -- Intellectual Disability
        'MD', -- Multiple disabilities
        'OI', -- Orthopedic impairment
        'OHI', -- Other health impairment
        'SLD', -- Specific learning disability
        'SLI', -- Speech or language impairment
        'TBI', -- Traumatic brain injury
        'VI' -- Visual impairment
    )),
    DisabilityConditionType TEXT CHECK (DisabilityConditionType IN (
        '00', -- No disability or impairment known or reported
        '01', -- Blindness or Visual Impairment
        '02', -- Cerebral Palsy
        '03', -- Chronic Illness
        '04', -- Deafness or Hearing Impairment
        '05', -- Drug or Alcohol Addiction
        '06', -- Emotionally/Psychologically Disabled
        '07', -- Epilepsy or Seizure Disorders
        '08', -- Intellectual Disability
        '09', -- Orthopedic Impairment
        '10', -- Specific learning disability
        '11', -- Speech or Language impairment
        '99' -- Other type of impairment
    )),
    DisabilityDeterminationSourceType TEXT CHECK (DisabilityDeterminationSourceType IN (
        '01', -- By physician
        '02', -- By health care provider
        '03', -- By school psychologist or other psychologist
        '04', -- By licensed physical therapist
        '05', -- Self-reported
        '06', -- By social service or other agency
        '97', -- Not applicable to the student
        '98', -- Unknown or Unreported
        '99' -- Other
    )),
    IDEAEducationalEnvironmentForSchoolAge TEXT CHECK (IDEAEducationalEnvironmentForSchoolAge IN (
        'RC80', -- Inside regular class 80% or more
        'RC79TO40', -- Inside regular class 40% to 79%
        'RC39', -- Inside regular class less than 40%
        'SS', -- Separate school
        'RF', -- Residential facility
        'HH', -- Homebound/hospital
        'CF', -- Correctional facility
        'PPPS' -- Parentally placed in private school
    )),
    ISO6392LanguageCode TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    ISO6393LanguageCode TEXT, -- ISO 639-3 language code, see http://www-01.sil.org/iso639-3/default.asp
    ISO6395LanguageFamily TEXT CHECK (ISO6395LanguageFamily IN (
        'aav', -- Austro-Asiatic languages
        'afa', -- Afro-Asiatic languages
        'alg', -- Algonquian languages
        'alv', -- Atlantic-Congo languages
        'apa', -- Apache languages
        'aqa', -- Alacalufan languages
        'aql', -- Algic languages
        'art', -- Artificial languages
        'ath', -- Athapascan languages
        'auf', -- Arauan languages
        'aus', -- Australian languages
        'awd', -- Arawakan languages
        'azc', -- Uto-Aztecan languages
        'bad', -- Banda languages
        'bai', -- Bamileke languages
        'bat', -- Baltic languages
        'ber', -- Berber languages
        'bih', -- Bihari languages
        'bnt', -- Bantu languages
        'btk', -- Batak languages
        'cai', -- Central American Indian languages
        'cau', -- Caucasian languages
        'cba', -- Chibchan languages
        'ccn', -- North Caucasian languages
        'ccs', -- South Caucasian languages
        'cdc', -- Chadic languages
        'cdd', -- Caddoan languages
        'cel', -- Celtic languages
        'cmc', -- Chamic languages
        'cpe', -- Creoles and pidgins, English-based
        'cpf', -- Creoles and pidgins, French-based
        'cpp', -- Creoles and pidgins, Portuguese-based
        'crp', -- Creoles and pidgins
        'csu', -- Central Sudanic languages
        'cus', -- Cushitic languages
        'day', -- Land Dayak languages
        'dmn', -- Mande languages
        'dra', -- Dravidian languages
        'egx', -- Egyptian languages
        'esx', -- Eskimo-Aleut languages
        'euq', -- Basque (family)
        'fiu', -- Finno-Ugrian languages
        'fox', -- Formosan languages
        'gem', -- Germanic languages
        'gme', -- East Germanic languages
        'gmq', -- North Germanic languages
        'gmw', -- West Germanic languages
        'grk', -- Greek languages
        'hmx', -- Hmong-Mien languages
        'hok', -- Hokan languages
        'hyx', -- Armenian (family)
        'iir', -- Indo-Iranian languages
        'ijo', -- Ijo languages
        'inc', -- Indic languages
        'ine', -- Indo-European languages
        'ira', -- Iranian languages
        'iro', -- Iroquoian languages
        'itc', -- Italic languages
        'jpx', -- Japanese (family)
        'kar', -- Karen languages
        'kdo', -- Kordofanian languages
        'khi', -- Khoisan languages
        'kro', -- Kru languages
        'map', -- Austronesian languages
        'mkh', -- Mon-Khmer languages
        'mno', -- Manobo languages
        'mun', -- Munda languages
        'myn', -- Mayan languages
        'nah', -- Nahuatl languages
        'nai', -- North American Indian languages
        'ngf', -- Trans-New Guinea languages
        'nic', -- Niger-Kordofanian languages
        'nub', -- Nubian languages
        'omq', -- Oto-Manguean languages
        'omv', -- Omotic languages
        'oto', -- Otomian languages
        'paa', -- Papuan languages
        'phi', -- Philippine languages
        'plf', -- Central Malayo-Polynesian languages
        'poz', -- Malayo-Polynesian languages
        'pqe', -- Eastern Malayo-Polynesian languages
        'pqw', -- Western Malayo-Polynesian languages
        'pra', -- Prakrit languages
        'qwe', -- Quechuan (family)
        'roa', -- Romance languages
        'sai', -- South American Indian languages
        'sal', -- Salishan languages
        'sdv', -- Eastern Sudanic languages
        'sem', -- Semitic languages
        'sgn', -- Sign languages
        'sio', -- Siouan languages
        'sit', -- Sino-Tibetan languages
        'sla', -- Slavic languages
        'smi', -- Sami languages
        'son', -- Songhai languages
        'sqj', -- Albanian languages
        'ssa', -- Nilo-Saharan languages
        'syd', -- Samoyedic languages
        'tai', -- Tai languages
        'tbq', -- Tibeto-Burman languages
        'trk', -- Turkic languages
        'tup', -- Tupi languages
        'tut', -- Altaic languages
        'tuw', -- Tungus languages
        'urj', -- Uralic languages
        'wak', -- Wakashan languages
        'wen', -- Sorbian languages
        'xgn', -- Mongolian languages
        'xnd', -- Na-Dene languages
        'ypk', -- Yupik languages
        'zhx', -- Chinese (family)
        'zle', -- East Slavic languages
        'zls', -- South Slavic languages
        'zlw', -- West Slavic languages
        'znd' -- Zande languages
    )),
    LanguageType TEXT CHECK (LanguageType IN (
        'Correspondence', -- Correspondence
        'Dominant', -- Dominant language
        'Home', -- Home language
        'Native', -- Native language
        'OtherLanguageProficiency', -- Other language proficiency
        'Other', -- Other
        'Spoken', -- Spoken Correspondence
        'Written' -- Written Correspondence
    )),
    ApplicationDate DATE, -- Date application received
    CTEConcentrator TEXT CHECK (CTEConcentrator IN ('Yes', 'No')),
    CTEParticipant TEXT CHECK (CTEParticipant IN ('Yes', 'No')),
    CareerPathwaysProgramParticipationIndicator TEXT CHECK (CareerPathwaysProgramParticipationIndicator IN ('Yes', 'No')),
    CareerPathwaysProgramParticipationStartDate DATE, -- Start date of career pathway program
    CareerPathwaysProgramParticipationExitDate DATE, -- Exit date of career pathway program
    CTEAEDisplacedHomemakerIndicator TEXT CHECK (CTEAEDisplacedHomemakerIndicator IN ('Yes', 'No')),
    OutOfWorkforceIndicator TEXT CHECK (OutOfWorkforceIndicator IN ('Yes', 'No', 'Unknown')),
    PerkinsPostProgramPlacementIndicator TEXT CHECK (PerkinsPostProgramPlacementIndicator IN (
        '1001', -- Advanced training
        '1010', -- Employment
        '1002', -- Military service
        '1101', -- National or community service
        '1003', -- National or community service or Peace Corps
        '9998', -- Not engaged Perkins Post-Program Placement
        '1009', -- Peace Corps
        '1007', -- Postsecondary associate degree
        '1008', -- Postsecondary baccalaureate degree
        '1006', -- Postsecondary certificate
        '1005', -- Postsecondary education
        '9997', -- Unknown
        '9999' -- Other
    )),
    ProgramEntryReason TEXT, -- Reason for program participation
    ProgramParticipationStartDate DATE, -- Start date of program
    ProgramParticipationExitDate DATE, -- Exit date of program
    Role TEXT CHECK (Role IN (
        'AEStaff', -- AE Staff
        'AEStudent', -- AE Student
        'CTEStaff', -- CTE Staff
        'CTEStudent', -- CTE Student
        'ELChild', -- EL Child
        'ELStaff', -- EL Staff
        'K12Staff', -- K12 Staff
        'K12Student', -- K12 Student
        'ParentGuardian', -- Parent/Guardian
        'PSApplicant', -- PS Applicant
        'PSStaff', -- PS Staff
        'PSStudent', -- PS Student
        'WorkforceProgramParticipant', -- Workforce Program Participant
        'ChiefStateSchoolOfficer', -- Chief State School Officer
        'SchoolBoardMember' -- School Board Member
    )),
    SingleParentOrSinglePregnantWomanStatus TEXT CHECK (SingleParentOrSinglePregnantWomanStatus IN ('Yes', 'No')),
    WorkBasedLearningOpportunityType TEXT CHECK (WorkBasedLearningOpportunityType IN (
        'Apprenticeship', -- Apprenticeship
        'ClinicalWork', -- Clinical work experience
        'CooperativeEducation', -- Cooperative education
        'JobShadowing', -- Job shadowing
        'Mentorship', -- Mentorship
        'NonPaidInternship', -- Non-Paid Internship
        'OnTheJob', -- On-the-Job
        'PaidInternship', -- Paid internship
        'ServiceLearning', -- Service learning
        'SupervisedAgricultural', -- Supervised agricultural experience
        'UnpaidInternship', -- Unpaid internship
        'Entrepreneurship', -- Entrepreneurship
        'SchoolBasedEnterprise', -- School-Based Enterprise
        'SimulatedWorksite', -- Simulated Worksite
        'Other' -- Other
    )),
    CareerCluster TEXT CHECK (CareerCluster IN (
        '01', -- Agriculture, Food & Natural Resources
        '02', -- Architecture & Construction
        '03', -- Arts, A/V Technology & Communications
        '04', -- Business Management & Administration
        '05', -- Education & Training
        '06', -- Finance
        '07', -- Government & Public Administration
        '08', -- Health Science
        '09', -- Hospitality & Tourism
        '10', -- Human Services
        '11', -- Information Technology
        '12', -- Law, Public Safety, Corrections & Security
        '13', -- Manufacturing
        '14', -- Marketing
        '15', -- Science, Technology, Engineering & Mathematics
        '16' -- Transportation, Distribution & Logistics
    )),
    CIPCode TEXT, -- Six-digit CIP code, see https://nces.ed.gov/ipeds/cipcode/browse.aspx?y=55
    CIPVersion TEXT CHECK (CIPVersion IN (
        'CIP1980', -- CIP 1980
        'CIP1985', -- CIP 1985
        'CIP1990', -- CIP 1990
        'CIP2000', -- CIP 2000
        'CIP2010', -- CIP 2010
        'CIP2020' -- CIP 2020
    )),
    AwaitingFosterCareStatus TEXT CHECK (AwaitingFosterCareStatus IN ('Yes', 'No')),
    CTENontraditionalGenderStatus TEXT CHECK (CTENontraditionalGenderStatus IN (
        'Underrepresented', -- Members of an underrepresented gender group
        'NotUnderrepresented' -- Not members of an underrepresented gender group
    )),
    PublicAssistanceStatus TEXT CHECK (PublicAssistanceStatus IN ('Yes', 'No')),
    PersonRelationshipType TEXT CHECK (PersonRelationshipType IN (
        'Aunt', -- Aunt
        'Brother', -- Brother
        'BrotherInLaw', -- Brother-in-law
        'CourtAppointedGuardian', -- Court appointed guardian
        'Daughter', -- Daughter
        'DaughterInLaw', -- Daughter-in-law
        'Employer', -- Employer
        'Father', -- Father
        'FathersSignificantOther', -- Father's significant other
        'FathersCivilPartner', -- Father's civil partner
        'FatherInLaw', -- Father-in-law
        'Fiance', -- Fiance
        'Fiancee', -- Fiancee
        'Friend', -- Friend
        'Grandfather', -- Grandfather
        'Grandmother', -- Grandmother
        'Husband', -- Husband
        'MothersSignificantOther', -- Mother's significant other
        'Mother', -- Mother
        'MothersCivilPartner', -- Mother's civil partner
        'Nephew', -- Nephew
        'Niece', -- Niece
        'Other', -- Other
        'SignificantOther', -- Significant other
        'Sister', -- Sister
        'Son', -- Son
        'Unknown', -- Unknown
        'Uncle', -- Uncle
        'Ward', -- Ward
        'Wife', -- Wife
        'AdoptedDaughter', -- Adopted Daughter
        'AdoptedSon', -- Adopted son
        'AdoptiveParent', -- Adoptive parent
        'Advisor', -- Advisor
        'AgencyRepresentative', -- Agency representative
        'Cousin', -- Cousin
        'Dependent', -- Dependent
        'FamilyMember', -- Family member
        'FormerHusband', -- Former husband
        'FormerWife', -- Former wife
        'FosterDaughter', -- Foster daughter
        'FosterFather', -- Foster father
        'FosterMother', -- Foster mother
        'FosterParent', -- Foster Parent
        'FosterSon', -- Foster son
        'Godparent', -- Godparent
        'Granddaughter', -- Granddaughter
        'Grandparent', -- Grandparent
        'Grandson', -- Grandson
        'GreatAunt', -- Great aunt
        'GreatGrandparent', -- Great grandparent
        'GreatUncle', -- Great uncle
        'HalfBrother', -- Half-brother
        'HalfSister', -- Half-sister
        'LifePartner', -- Life partner
        'LifePartnerOfParent', -- Life partner of parent
        'MotherInLaw', -- Mother-in-law
        'Neighbor', -- Neighbor
        'Parent', -- Parent
        'Partner', -- Partner
        'PartnerOfParent', -- Partner of parent
        'ProbationOfficer', -- Probation officer
        'Relative', -- Relative
        'Sibling', -- Sibling
        'SisterInLaw', -- Sister-in-law
        'SonInLaw', -- Son-in-law
        'Spouse', -- Spouse
        'Stepbrother', -- Stepbrother
        'Stepdaughter', -- Stepdaughter
        'Stepfather', -- Stepfather
        'Stepmother', -- Stepmother
        'Stepparent', -- Stepparent
        'Stepsister', -- Stepsister
        'Stepson' -- Stepson
    ))
);

-- Creating table for Program entity
CREATE TABLE CTEProgram (
    ProgramName TEXT, -- Name of the program
    EnrollmentCapacity INTEGER, -- Max age-appropriate students
    PrimaryProgramIndicator TEXT CHECK (PrimaryProgramIndicator IN ('Yes', 'No')),
    CareerCluster TEXT CHECK (CareerCluster IN (
        '01', -- Agriculture, Food & Natural Resources
        '02', -- Architecture & Construction
        '03', -- Arts, A/V Technology & Communications
        '04', -- Business Management & Administration
        '05', -- Education & Training
        '06', -- Finance
        '07', -- Government & Public Administration
        '08', -- Health Science
        '09', -- Hospitality & Tourism
        '10', -- Human Services
        '11', -- Information Technology
        '12', -- Law, Public Safety, Corrections & Security
        '13', -- Manufacturing
        '14', -- Marketing
        '15', -- Science, Technology, Engineering & Mathematics
        '16' -- Transportation, Distribution & Logistics
    )),
    ProgramSponsorType TEXT CHECK (ProgramSponsorType IN (
        'Business', -- Business
        'EducationOrganizationNetwork', -- Education organization network
        'EducationServiceCenter', -- Education Service Center
        'Federal', -- Federal government
        'LEA', -- Local education agency
        'NonProfit', -- Non-profit organization
        'Postsecondary', -- Postsecondary institution
        'Private', -- Private organization
        'Regional', -- Regional or intermediate education agency
        'Religious', -- Religious organization
        'School', -- School
        'SEA', -- State Education Agency
        'Other' -- Other
    )),
    ProgramType TEXT CHECK (ProgramType IN (
        '73056', -- Adult Basic Education
        '73058', -- Adult English as a Second Language
        '73057', -- Adult Secondary Education
        '04961', -- Alternative Education
        '04932', -- Athletics
        '04923', -- Bilingual education program
        '04906', -- Career and Technical Education
        '04931', -- Cocurricular programs
        '04958', -- College preparatory
        '04945', -- Community service program
        '04944', -- Community/junior college education program
        '04922', -- Compensatory services for disadvantaged students
        '73059', -- Continuing Education
        '04956', -- Counseling services
        '14609', -- Early Head Start
        '04928', -- English as a second language (ESL) program
        '04919', -- Even Start
        '04955', -- Extended day/child care services
        '75000', -- Foster Care
        '04930', -- Gifted and talented program
        '04918', -- Head start
        '04963', -- Health Services Program
        '04957', -- Immigrant education
        '04921', -- Indian education
        '04959', -- International Baccalaureate
        '04962', -- Library/Media Services Program
        '04960', -- Magnet/Special Program Emphasis
        '04920', -- Migrant education
        '04887', -- Regular education
        '04964', -- Remedial education
        '04967', -- Section 504 Placement
        '04966', -- Service learning
        '04888', -- Special Education Services
        '04954', -- Student retention/Dropout Prevention
        '04953', -- Substance abuse education/prevention
        '73204', -- Targeted intervention program
        '04968', -- Teacher professional development/Mentoring
        '04917', -- Technical preparatory
        '75001', -- Title I
        '73090', -- Work-based Learning Opportunities
        '75014', -- Autism program
        '75015', -- Early childhood special education tier one
        '09999', -- Other
        '75016', -- Early childhood special education tier two
        '75002', -- Early College
        '75006', -- Emotional disturbance program
        '75008', -- Hearing impairment program
        '75017', -- K12 Resource Program
        '75003', -- Mild cognitive disability program
        '75004', -- Moderate cognitive disability program
        '75012', -- Multiple disabilities program
        '75011', -- Orthopedic impairment
        '75010', -- Other health impairment
        '75005', -- Significant cognitive disability program
        '75007', -- Specific learning disability program
        '75013', -- Speech or language impairment program
        '75009', -- Visual impairment program
        '75018', -- Hospital
        '76000', -- McKinney-Vento Homeless
        '77000', -- Title III LIEP
        '75019', -- Neglected or delinquent
        '75020' -- TANF
    ))
);

-- Creating table for Assessment entity
CREATE TABLE Assessment (
    AssessmentGUID TEXT, -- RFC 4122 compliant GUID, up to 40 chars with hash
    AssessmentIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    AssessmentIdentificationSystem TEXT CHECK (AssessmentIdentificationSystem IN (
        'School', -- School-assigned number
        'District', -- District-assigned number
        'State', -- State-assigned number
        'Federal', -- Federal identification number
        'OtherFederal', -- Other federally assigned number
        'TestContractor', -- Test contractor assigned assessment number
        'Other' -- Other
    )),
    AssessmentTitle TEXT NOT NULL, -- Full title of the assessment
    AssessmentShortName TEXT, -- Abbreviated title
    AssessmentFamilyTitle TEXT, -- Full title of the assessment family
    AssessmentFamilyShortName TEXT, -- Abbreviated title of the assessment family
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    )),
    AssessmentEarlyLearningDevelopmentalDomain TEXT CHECK (AssessmentEarlyLearningDevelopmentalDomain IN (
        '01', -- Language and Literacy
        '02', -- Cognition and General Knowledge
        '03', -- Approaches Toward Learning
        '04', -- Physical Well-being and Motor
        '05' -- Social and Emotional Development
    )),
    AssessmentLevelForWhichDesigned TEXT CHECK (AssessmentLevelForWhichDesigned IN (
        'Birth', -- Birth
        'Prenatal', -- Prenatal
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    AssessmentObjective TEXT, -- Objective the assessment measures
    AssessmentProvider TEXT, -- Provider or publisher of the assessment
    AssessmentPurpose TEXT CHECK (AssessmentPurpose IN (
        '00050', -- Admission
        '00051', -- Assessment of student's progress
        '73055', -- College Readiness
        '00063', -- Course credit
        '00064', -- Course requirement
        '73069', -- Diagnosis
        '03459', -- Federal accountability
        '73068', -- Inform local or state policy
        '00055', -- Instructional decision
        '03457', -- Local accountability
        '02400', -- Local graduation requirement
        '73042', -- Obtain a state- or industry-recognized certificate or license
        '73043', -- Obtain postsecondary credit for the course
        '73067', -- Program eligibility
        '00057', -- Program evaluation
        '00058', -- Program placement
        '00062', -- Promotion to or retention in a grade or program
        '00061', -- Screening
        '03458', -- State accountability
        '09999', -- Other
        '00054' -- State graduation requirement
    )),
    AssessmentRevisionDate DATE, -- Date of substantial revision
    AssessmentScoreMetricType TEXT CHECK (AssessmentScoreMetricType IN (
        '00512', -- Achievement/proficiency level
        '00494', -- ACT score
        '00490', -- Age score
        '00491', -- C-scaled scores
        '00492', -- College Board examination scores
        '00493', -- Grade equivalent or grade-level indicator
        '03473', -- Graduation score
        '03474', -- Growth/value-added/indexing
        '03475', -- International Baccalaureate score
        '00144', -- Letter grade/mark
        '00513', -- Mastery level
        '00497', -- Normal curve equivalent
        '00498', -- Normalized standard score
        '00499', -- Number score
        '00500', -- Pass-fail
        '03476', -- Percentile
        '00502', -- Percentile rank
        '00503', -- Proficiency level
        '03477', -- Promotion score
        '00504', -- Ranking
        '00505', -- Ratio IQ's
        '03478', -- Raw score
        '03479', -- Scale score
        '00506', -- Standard age score
        '00508', -- Stanine score
        '00509', -- Sten score
        '00510', -- T-score
        '03480', -- Workplace readiness score
        '00511', -- Z-score
        '03481', -- SAT Score
        '09999' -- Other
    )),
    AssessmentType TEXT CHECK (AssessmentType IN (
        'AchievementTest', -- Achievement test
        'AdvancedPlacementTest', -- Advanced placement test
        'AlternateAssessmentELL', -- Alternate assessment/ELL
        'AlternateAssessmentGradeLevelStandards', -- Alternate assessment/grade-level standards
        'AlternativeAssessmentModifiedStandards', -- Alternative assessment/modified standards
        'AptitudeTest', -- Aptitude Test
        'Benchmark', -- Benchmark
        'CognitiveAndPerceptualSkills', -- Cognitive and perceptual skills test
        'ComputerAdaptiveTest', -- Computer Adaptive Test
        'DevelopmentalObservation', -- Developmental observation
        'Diagnostic', -- Diagnostic
        'DirectAssessment', -- Direct Assessment
        'Formative', -- Formative
        'GrowthMeasure', -- Growth Measure
        'Interim', -- Interim
        'KindergartenReadiness', -- Kindergarten Readiness
        'LanguageProficiency', -- Language proficiency test
        'MentalAbility', -- Mental ability (intelligence) test
        'Observation', -- Observation
        'ParentReport', -- Parent Report
        'PerformanceAssessment', -- Performance assessment
        'PortfolioAssessment', -- Portfolio assessment
        'PrekindergartenReadiness', -- Prekindergarten Readiness
        'ReadingReadiness', -- Reading readiness test
        'Screening', -- Screening
        'TeacherReport', -- Teacher Report
        'AlternateAssessmentAlternateStandards', -- Alternate assessment/alternate standards
        'WorkplaceSkills', -- Workplace skills
        'Other' -- Other
    )),
    AssessmentTypeAdministered TEXT CHECK (AssessmentTypeAdministered IN (
        'REGASSWOACC', -- Regular assessments based on grade-level achievement standards without accommodations
        'REGASSWACC', -- Regular assessments based on grade-level achievement standards with accommodations
        'ALTASSGRADELVL', -- Alternate assessments based on grade-level achievement standards
        'ALTASSMODACH', -- Alternate assessments based on modified achievement standards
        'ALTASSALTACH', -- Alternate assessments based on alternate achievement standards
        'AgeLevelWithoutAccommodations', -- Assessment based on age level standards without accommodations
        'AgeLevelWithAccommodations', -- Assessment based on age level standards with accommodations
        'BelowAgeLevelWithoutAccommodations', -- Assessment based on standards below age level without accommodations
        'BelowAgeLevelWithAccommodations' -- Assessment based on standards below age level with accommodations
    )),
    AssessmentTypeAdministeredToEnglishLearners TEXT CHECK (AssessmentTypeAdministeredToEnglishLearners IN (
        'ALTELPASMNTALT', -- Alternate English language proficiency (ELP) based on alternate ELP achievement standards
        'REGELPASMNT' -- Regular English language proficiency (ELP) assessment
    )),
    ISO6392LanguageCode TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    ISO6393LanguageCode TEXT, -- ISO 639-3 language code, see http://www-01.sil.org/iso639-3/default.asp
    ISO6395LanguageFamily TEXT CHECK (ISO6395LanguageFamily IN (
        'aav', -- Austro-Asiatic languages
        'afa', -- Afro-Asiatic languages
        'alg', -- Algonquian languages
        'alv', -- Atlantic-Congo languages
        'apa', -- Apache languages
        'aqa', -- Alacalufan languages
        'aql', -- Algic languages
        'art', -- Artificial languages
        'ath', -- Athapascan languages
        'auf', -- Arauan languages
        'aus', -- Australian languages
        'awd', -- Arawakan languages
        'azc', -- Uto-Aztecan languages
        'bad', -- Banda languages
        'bai', -- Bamileke languages
        'bat', -- Baltic languages
        'ber', -- Berber languages
        'bih', -- Bihari languages
        'bnt', -- Bantu languages
        'btk', -- Batak languages
        'cai', -- Central American Indian languages
        'cau', -- Caucasian languages
        'cba', -- Chibchan languages
        'ccn', -- North Caucasian languages
        'ccs', -- South Caucasian languages
        'cdc', -- Chadic languages
        'cdd', -- Caddoan languages
        'cel', -- Celtic languages
        'cmc', -- Chamic languages
        'cpe', -- Creoles and pidgins, English-based
        'cpf', -- Creoles and pidgins, French-based
        'cpp', -- Creoles and pidgins, Portuguese-based
        'crp', -- Creoles and pidgins
        'csu', -- Central Sudanic languages
        'cus', -- Cushitic languages
        'day', -- Land Dayak languages
        'dmn', -- Mande languages
        'dra', -- Dravidian languages
        'egx', -- Egyptian languages
        'esx', -- Eskimo-Aleut languages
        'euq', -- Basque (family)
        'fiu', -- Finno-Ugrian languages
        'fox', -- Formosan languages
        'gem', -- Germanic languages
        'gme', -- East Germanic languages
        'gmq', -- North Germanic languages
        'gmw', -- West Germanic languages
        'grk', -- Greek languages
        'hmx', -- Hmong-Mien languages
        'hok', -- Hokan languages
        'hyx', -- Armenian (family)
        'iir', -- Indo-Iranian languages
        'ijo', -- Ijo languages
        'inc', -- Indic languages
        'ine', -- Indo-European languages
        'ira', -- Iranian languages
        'iro', -- Iroquoian languages
        'itc', -- Italic languages
        'jpx', -- Japanese (family)
        'kar', -- Karen languages
        'kdo', -- Kordofanian languages
        'khi', -- Khoisan languages
        'kro', -- Kru languages
        'map', -- Austronesian languages
        'mkh', -- Mon-Khmer languages
        'mno', -- Manobo languages
        'mun', -- Munda languages
        'myn', -- Mayan languages
        'nah', -- Nahuatl languages
        'nai', -- North American Indian languages
        'ngf', -- Trans-New Guinea languages
        'nic', -- Niger-Kordofanian languages
        'nub', -- Nubian languages
        'omq', -- Oto-Manguean languages
        'omv', -- Omotic languages
        'oto', -- Otomian languages
        'paa', -- Papuan languages
        'phi', -- Philippine languages
        'plf', -- Central Malayo-Polynesian languages
        'poz', -- Malayo-Polynesian languages
        'pqe', -- Eastern Malayo-Polynesian languages
        'pqw', -- Western Malayo-Polynesian languages
        'pra', -- Prakrit languages
        'qwe', -- Quechuan (family)
        'roa', -- Romance languages
        'sai', -- South American Indian languages
        'sal', -- Salishan languages
        'sdv', -- Eastern Sudanic languages
        'sem', -- Semitic languages
        'sgn', -- Sign languages
        'sio', -- Siouan languages
        'sit', -- Sino-Tibetan languages
        'sla', -- Slavic languages
        'smi', -- Sami languages
        'son', -- Songhai languages
        'sqj', -- Albanian languages
        'ssa', -- Nilo-Saharan languages
        'syd', -- Samoyedic languages
        'tai', -- Tai languages
        'tbq', -- Tibeto-Burman languages
        'trk', -- Turkic languages
        'tup', -- Tupi languages
        'tut', -- Altaic languages
        'tuw', -- Tungus languages
        'urj', -- Uralic languages
        'wak', -- Wakashan languages
        'wen', -- Sorbian languages
        'xgn', -- Mongolian languages
        'xnd', -- Na-Dene languages
        'ypk', -- Yupik languages
        'zhx', -- Chinese (family)
        'zle', -- East Slavic languages
        'zls', -- South Slavic languages
        'zlw', -- West Slavic languages
        'znd' -- Zande languages
    ))
);

-- Creating table for Assessment Administration entity
CREATE TABLE AssessmentAdministration (
    AssessmentAdministrationCode TEXT, -- Code for the assessment event
    AssessmentAdministrationName TEXT, -- Name of the assessment event
    AssessmentAdministrationAssessmentFamily TEXT, -- Title of the assessment family
    AssessmentAdministrationOrganizationName TEXT, -- Name of the responsible organization
    AssessmentAdministrationStartDate DATE, -- Start date of administration period
    AssessmentAdministrationStartTime TEXT, -- Start time of administration period
    AssessmentAdministrationFinishDate DATE, -- Finish date of administration period
    AssessmentAdministrationFinishTime TEXT, -- Finish time of administration period
    AssessmentAdministrationPeriodDescription TEXT, -- Description of administration period
    AssessmentIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    AssessmentIdentificationSystem TEXT CHECK (AssessmentIdentificationSystem IN (
        'School', -- School-assigned number
        'District', -- District-assigned number
        'State', -- State-assigned number
        'Federal', -- Federal identification number
        'OtherFederal', -- Other federally assigned number
        'TestContractor', -- Test contractor assigned assessment number
        'Other' -- Other
    )),
    AssessmentSecureIndicator TEXT CHECK (AssessmentSecureIndicator IN ('Yes', 'No')),
    LocalEducationAgencyIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    LEAIdentificationSystem TEXT CHECK (LEAIdentificationSystem IN (
        'District', -- District-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'CENSUSID', -- Census Bureau identification code
        'OtherFederal', -- Other federally assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    )),
    SchoolIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    SchoolIdentificationSystem TEXT CHECK (SchoolIdentificationSystem IN (
        'School', -- School-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'LEA', -- Local Education Agency assigned number
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'OtherFederal', -- Other federally assigned number
        'StateUniversitySystem', -- State University System assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    ))
);

-- Creating table for Assessment Asset entity
CREATE TABLE AssessmentAsset (
    AssessmentAssetIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    AssessmentAssetIdentifierType TEXT CHECK (AssessmentAssetIdentifierType IN (
        'Client', -- Assigned by the client
        'Publisher', -- Assigned by the asset owner
        'Internal', -- Provided by an internal assessment service
        'Other' -- Custom identifier
    )),
    AssessmentAssetName TEXT, -- Name of the assessment asset
    AssessmentAssetOwner TEXT, -- Name of the ownership rights holder or publisher
    AssessmentAssetContentXML TEXT, -- XML content encoded in UTF-8
    AssessmentAssetContentMimeType TEXT, -- MIME type of the content
    AssessmentAssetContentURL TEXT, -- URL location of external content
    AssessmentAssetPublishedDate DATE, -- Date the version was made available
    AssessmentAssetType TEXT CHECK (AssessmentAssetType IN (
        'ReadingPassage', -- Reading passage
        'GraphicArt', -- Graphic art
        'Map', -- Map
        'FormulaSheet', -- Formula sheet
        'Table', -- Table
        'Chart', -- Chart
        'Audio', -- Audio
        'Video', -- Video
        'Scenario', -- Scenario
        'Simulation', -- Simulation
        'StoryBoard', -- Story board
        'LabSet', -- Lab set
        'PeriodicTable', -- Periodic table
        'TranslationDictionary', -- Translation dictionary
        'BasicCalculator', -- Basic calculator
        'StandardCalculator', -- Standard calculator
        'ScientificCalculator', -- Scientific calculator
        'GraphingCalculator', -- Graphing calculator
        'Protractor', -- Protractor
        'MetricRuler', -- Metric ruler
        'EnglishRuler', -- English ruler
        'UnitsRuler', -- Units ruler
        'ReadingLine', -- Reading line
        'LineDraw', -- Line draw
        'Highlighter', -- Highlighter
        'OtherInteractive', -- Other interactive
        'OtherNonInteractive', -- Other non-interactive
        'Other' -- Other
    )),
    AssessmentAssetVersion TEXT, -- Version number or label
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    )),
    AssessmentLevelForWhichDesigned TEXT CHECK (AssessmentLevelForWhichDesigned IN (
        'Birth', -- Birth
        'Prenatal', -- Prenatal
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    ISO6392LanguageCode TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    ISO6393LanguageCode TEXT, -- ISO 639-3 language code, see http://www-01.sil.org/iso639-3/default.asp
    ISO6395LanguageFamily TEXT CHECK (ISO6395LanguageFamily IN (
        'aav', -- Austro-Asiatic languages
        'afa', -- Afro-Asiatic languages
        'alg', -- Algonquian languages
        'alv', -- Atlantic-Congo languages
        'apa', -- Apache languages
        'aqa', -- Alacalufan languages
        'aql', -- Algic languages
        'art', -- Artificial languages
        'ath', -- Athapascan languages
        'auf', -- Arauan languages
        'aus', -- Australian languages
        'awd', -- Arawakan languages
        'azc', -- Uto-Aztecan languages
        'bad', -- Banda languages
        'bai', -- Bamileke languages
        'bat', -- Baltic languages
        'ber', -- Berber languages
        'bih', -- Bihari languages
        'bnt', -- Bantu languages
        'btk', -- Batak languages
        'cai', -- Central American Indian languages
        'cau', -- Caucasian languages
        'cba', -- Chibchan languages
        'ccn', -- North Caucasian languages
        'ccs', -- South Caucasian languages
        'cdc', -- Chadic languages
        'cdd', -- Caddoan languages
        'cel', -- Celtic languages
        'cmc', -- Chamic languages
        'cpe', -- Creoles and pidgins, English-based
        'cpf', -- Creoles and pidgins, French-based
        'cpp', -- Creoles and pidgins, Portuguese-based
        'crp', -- Creoles and pidgins
        'csu', -- Central Sudanic languages
        'cus', -- Cushitic languages
        'day', -- Land Dayak languages
        'dmn', -- Mande languages
        'dra', -- Dravidian languages
        'egx', -- Egyptian languages
        'esx', -- Eskimo-Aleut languages
        'euq', -- Basque (family)
        'fiu', -- Finno-Ugrian languages
        'fox', -- Formosan languages
        'gem', -- Germanic languages
        'gme', -- East Germanic languages
        'gmq', -- North Germanic languages
        'gmw', -- West Germanic languages
        'grk', -- Greek languages
        'hmx', -- Hmong-Mien languages
        'hok', -- Hokan languages
        'hyx', -- Armenian (family)
        'iir', -- Indo-Iranian languages
        'ijo', -- Ijo languages
        'inc', -- Indic languages
        'ine', -- Indo-European languages
        'ira', -- Iranian languages
        'iro', -- Iroquoian languages
        'itc', -- Italic languages
        'jpx', -- Japanese (family)
        'kar', -- Karen languages
        'kdo', -- Kordofanian languages
        'khi', -- Khoisan languages
        'kro', -- Kru languages
        'map', -- Austronesian languages
        'mkh', -- Mon-Khmer languages
        'mno', -- Manobo languages
        'mun', -- Munda languages
        'myn', -- Mayan languages
        'nah', -- Nahuatl languages
        'nai', -- North American Indian languages
        'ngf', -- Trans-New Guinea languages
        'nic', -- Niger-Kordofanian languages
        'nub', -- Nubian languages
        'omq', -- Oto-Manguean languages
        'omv', -- Omotic languages
        'oto', -- Otomian languages
        'paa', -- Papuan languages
        'phi', -- Philippine languages
        'plf', -- Central Malayo-Polynesian languages
        'poz', -- Malayo-Polynesian languages
        'pqe', -- Eastern Malayo-Polynesian languages
        'pqw', -- Western Malayo-Polynesian languages
        'pra', -- Prakrit languages
        'qwe', -- Quechuan (family)
        'roa', -- Romance languages
        'sai', -- South American Indian languages
        'sal', -- Salishan languages
        'sdv', -- Eastern Sudanic languages
        'sem', -- Semitic languages
        'sgn', -- Sign languages
        'sio', -- Siouan languages
        'sit', -- Sino-Tibetan languages
        'sla', -- Slavic languages
        'smi', -- Sami languages
        'son', -- Songhai languages
        'sqj', -- Albanian languages
        'ssa', -- Nilo-Saharan languages
        'syd', -- Samoyedic languages
        'tai', -- Tai languages
        'tbq', -- Tibeto-Burman languages
        'trk', -- Turkic languages
        'tup', -- Tupi languages
        'tut', -- Altaic languages
        'tuw', -- Tungus languages
        'urj', -- Uralic languages
        'wak', -- Wakashan languages
        'wen', -- Sorbian languages
        'xgn', -- Mongolian languages
        'xnd', -- Na-Dene languages
        'ypk', -- Yupik languages
        'zhx', -- Chinese (family)
        'zle', -- East Slavic languages
        'zls', -- South Slavic languages
        'zlw', -- West Slavic languages
        'znd' -- Zande languages
    ))
);

-- Creating table for Assessment Form entity
CREATE TABLE AssessmentForm (
    AssessmentFormGUID TEXT, -- RFC 4122 compliant GUID, up to 40 chars with hash
    AssessmentFormName TEXT, -- Name of the assessment form
    AssessmentFormNumber TEXT, -- Number of the assessment form
    AssessmentFormVersion TEXT, -- Version number of the form
    AssessmentFormAccommodationList TEXT, -- List of available accommodations
    AssessmentFormPlatformsSupported TEXT, -- List of supported delivery platforms
    IntendedAdministrationStartDate DATE, -- Start date of intended administration
    AssessmentFormIntendedAdministrationEndDate DATE, -- End date of intended administration
    LearningResourcePublishedDate DATE, -- Published date of the form
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    )),
    AssessmentFormAdaptiveIndicator TEXT CHECK (AssessmentFormAdaptiveIndicator IN ('Yes', 'No')),
    AssessmentFormAlgorithmIdentifier TEXT, -- Identifier for adaptive test algorithm
    AssessmentFormAlgorithmVersion TEXT, -- Version of adaptive test algorithm
    AssessmentLanguage TEXT, -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
    AssessmentLevelForWhichDesigned TEXT CHECK (AssessmentLevelForWhichDesigned IN (
        'Birth', -- Birth
        'Prenatal', -- Prenatal
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    AssessmentSecureIndicator TEXT CHECK (AssessmentSecureIndicator IN ('Yes', 'No'))
);

-- Creating table for Assessment Form Section entity
CREATE TABLE AssessmentFormSection (
    AssessmentFormSectionGUID TEXT, -- RFC 4122 compliant GUID, up to 40 chars with hash
    AssessmentFormSectionIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    IdentificationSystemForAssessmentFormSection TEXT CHECK (IdentificationSystemForAssessmentFormSection IN (
        'Client', -- Client
        'Publisher', -- Publisher
        'Internal', -- Internal
        'Other' -- Other
    )),
    AssessmentFormSectionVersion TEXT, -- Version number of the section
    AssessmentFormSectionSequenceNumber INTEGER, -- Position in sequence of sections
    AssessmentFormSectionTimeLimit TEXT, -- Maximum time allowed for the section
    AssessmentFormSectionReentry TEXT CHECK (AssessmentFormSectionReentry IN ('Yes', 'No')),
    AssessmentFormSectionSealed TEXT CHECK (AssessmentFormSectionSealed IN ('Yes', 'No')),
    AssessmentFormSectionItemFieldTestIndicator TEXT CHECK (AssessmentFormSectionItemFieldTestIndicator IN ('Yes', 'No')),
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    )),
    AssessmentFormAlgorithmIdentifier TEXT, -- Identifier for adaptive test algorithm
    LearningResourcePublishedDate DATE -- Published date of the section
);

-- Creating table for Assessment Form Subtest Assessment Item entity
CREATE TABLE AssessmentFormSubtestAssessmentItem (
    AssessmentFormSubtestItemWeightCorrect REAL, -- Weight for correct/partially correct item
    AssessmentFormSubtestItemWeightIncorrect REAL, -- Weight for incorrect item
    AssessmentFormSubtestItemWeightNotAttempted REAL -- Weight for not attempted item
);

-- Creating table for Assessment Item entity
CREATE TABLE AssessmentItem (
    AssessmentItemIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    AssessmentItemBankIdentifier TEXT, -- Unique identifier for item bank
    AssessmentItemBankName TEXT, -- Name of the item bank
    AssessmentItemBodyText TEXT, -- Complete text of the assessment item
    AssessmentItemDifficulty REAL, -- Percentage of correct answers during trial
    AssessmentItemDistractorAnalysis TEXT, -- Analysis of distractors
    AssessmentItemAllottedTime TEXT, -- Time allotted for the item
    AssessmentItemMaximumScore REAL, -- Maximum points possible
    AssessmentItemMinimumScore REAL, -- Minimum points possible
    AssessmentItemLinkingItemIndicator TEXT CHECK (AssessmentItemLinkingItemIndicator IN ('Yes', 'No')),
    AssessmentItemReleaseStatus TEXT CHECK (AssessmentItemReleaseStatus IN ('Yes', 'No')),
    AssessmentItemResponseSecurityIssue TEXT, -- Description of security issues
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    ))
);

-- Creating table for Assessment Registration entity
CREATE TABLE AssessmentRegistration (
    ReasonNotTested TEXT CHECK (ReasonNotTested IN (
        '03451', -- Absent
        '03455', -- Disruptive behavior
        '03454', -- Medical waiver
        '03456', -- Previously passed the examination
        '03452', -- Refusal by parent
        '03453', -- Refusal by student
        '09999' -- Other
    )),
    SchoolFullAcademicYear TEXT CHECK (SchoolFullAcademicYear IN ('Yes', 'No')),
    StateFullAcademicYear TEXT CHECK (StateFullAcademicYear IN ('Yes', 'No')),
    SchoolIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    SchoolIdentificationSystem TEXT CHECK (SchoolIdentificationSystem IN (
        'School', -- School-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'LEA', -- Local Education Agency assigned number
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'OtherFederal', -- Other federally assigned number
        'StateUniversitySystem', -- State University System assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    )),
    StateAgencyIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    StateAgencyIdentificationSystem TEXT CHECK (StateAgencyIdentificationSystem IN (
        'State', -- State-assigned number
        'Federal', -- Federal identification number
        'FEIN', -- Federal Employer Identification Number
        'NCES', -- National Center for Education Statistics Assigned Number
        'SAM', -- System for Award Management Unique Entity Identifier
        'Other' -- Other
    )),
    LocalEducationAgencyIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    LEAIdentificationSystem TEXT CHECK (LEAIdentificationSystem IN (
        'District', -- District-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'CENSUSID', -- Census Bureau identification code
        'OtherFederal', -- Other federally assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    ))
);

-- Creating table for Assessment Result entity
CREATE TABLE AssessmentResult (
    AssessmentResultScoreValue TEXT, -- Score value (number, percentile, range, etc.)
    AssessmentResultDataType TEXT CHECK (AssessmentResultDataType IN (
        'Integer', -- Integer
        'Decimal', -- Decimal
        'Percentile', -- Percentile
        'String' -- String
    )),
    AssessmentResultDateCreated DATE, -- Date result was generated
    AssessmentResultDateUpdated DATE, -- Most recent date result was updated
    AssessmentResultDescriptiveFeedback TEXT, -- Formative feedback given to learner
    AssessmentResultDescriptiveFeedbackDateTime TEXT, -- Date and time feedback was entered
    AssessmentResultDescriptiveFeedbackSource TEXT, -- Source of feedback
    AssessmentResultDiagnosticStatement TEXT, -- Statement for professional interpretation
    AssessmentResultNumberOfResponses INTEGER, -- Number of attempted responses
    AssessmentResultPreliminaryIndicator TEXT CHECK (AssessmentResultPreliminaryIndicator IN ('Yes', 'No')),
    AssessmentResultPretestOutcome TEXT CHECK (AssessmentResultPretestOutcome IN (
        'GradeLevel', -- At or above Grade Level
        'BelowGradeLevel', -- Below Grade Level
        'NA' -- Not applicable
    )),
    AssessmentResultScoreStandardError REAL, -- Standard error of the score
    AssessmentResultScoreType TEXT CHECK (AssessmentResultScoreType IN (
        'Initial', -- An initial assessment score instance
        'Reliability', -- Recorded as a measure of reliability
        'Resolution', -- Recorded after resolution of scoring issues
        'Backread', -- Recorded to check scorer accuracy
        'Final' -- The final assessment score instance
    )),
    AssessmentScoreMetricType TEXT CHECK (AssessmentScoreMetricType IN (
        '00512', -- Achievement/proficiency level
        '00494', -- ACT score
        '00490', -- Age score
        '00491', -- C-scaled scores
        '00492', -- College Board examination scores
        '00493', -- Grade equivalent or grade-level indicator
        '03473', -- Graduation score
        '03474', -- Growth/value-added/indexing
        '03475', -- International Baccalaureate score
        '00144', -- Letter grade/mark
        '00513', -- Mastery level
        '00497', -- Normal curve equivalent
        '00498', -- Normalized standard score
        '00499', -- Number score
        '00500', -- Pass-fail
        '03476', -- Percentile
        '00502', -- Percentile rank
        '00503', -- Proficiency level
        '03477', -- Promotion score
        '00504', -- Ranking
        '00505', -- Ratio IQ's
        '03478', -- Raw score
        '03479', -- Scale score
        '00506', -- Standard age score
        '00508', -- Stanine score
        '00509', -- Sten score
        '00510', -- T-score
        '03480', -- Workplace readiness score
        '00511', -- Z-score
        '03481', -- SAT Score
        '09999' -- Other
    )),
    DiagnosticStatementSource TEXT, -- Source of diagnostic statement
    InstructionalRecommendation TEXT -- Next steps for instruction
);

-- Creating table for Assessment Performance Level entity
CREATE TABLE AssessmentPerformanceLevel (
    AssessmentPerformanceLevelIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    AssessmentPerformanceLevelLabel TEXT, -- Label for reporting
    AssessmentPerformanceLevelDescriptiveFeedback TEXT, -- Feedback message for the level
    AssessmentPerformanceLevelLowerCutScore REAL, -- Lowest score for the level
    AssessmentPerformanceLevelUpperCutScore REAL, -- Highest score for the level
    AssessmentPerformanceLevelScoreMetric TEXT CHECK (AssessmentPerformanceLevelScoreMetric IN (
        '00512', -- Achievement/proficiency level
        '00494', -- ACT score
        '00490', -- Age score
        '00491', -- C-scaled scores
        '00492', -- College Board examination scores
        '00493', -- Grade equivalent or grade-level indicator
        '03473', -- Graduation score
        '03474', -- Growth/value-added/indexing
        '03475', -- International Baccalaureate score
        '00144', -- Letter grade/mark
        '00513', -- Mastery level
        '00497', -- Normal curve equivalent
        '00498', -- Normalized standard score
        '00499', -- Number score
        '00500', -- Pass-fail
        '03476', -- Percentile
        '00502', -- Percentile rank
        '00503', -- Proficiency level
        '03477', -- Promotion score
        '00504', -- Ranking
        '00505', -- Ratio IQ's
        '03478', -- Raw score
        '03479', -- Scale score
        '00506', -- Standard age score
        '00508', -- Stanine score
        '00509', -- Sten score
        '00510', -- T-score
        '03480', -- Workplace readiness score
        '00511', -- Z-score
        '09999' -- Other
    ))
);

-- Creating table for Scorer entity
CREATE TABLE Scorer (
    PersonIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    PersonIdentificationSystem TEXT CHECK (PersonIdentificationSystem IN (
        'SSN', -- Social Security Administration number
        'USVisa', -- US government Visa number
        'PIN', -- Personal identification number
        'Federal', -- Federal identification number
        'DriversLicense', -- Driver's license number
        'Medicaid', -- Medicaid number
        'HealthRecord', -- Health record number
        'ProfessionalCertificate', -- Professional certificate or license number
        'School', -- School-assigned number
        'District', -- District-assigned number
        'State', -- State-assigned number
        'Institution', -- Institution-assigned number
        'OtherFederal', -- Other federally assigned number
        'SelectiveService', -- Selective Service Number
        'CanadianSIN', -- Canadian Social Insurance Number
        'BirthCertificate', -- Birth certificate number
        'Other' -- Other
    )),
    FirstName TEXT, -- Legal first name
    LastOrSurname TEXT -- Legal last name
);

-- Creating table for Assessment Session entity
CREATE TABLE AssessmentSession (
    AssessmentSessionAdministratorIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    AssessmentSessionProctorIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    AssessmentSessionAllottedTime TEXT, -- Duration of allotted time
    AssessmentSessionLocation TEXT, -- Description of administration place
    AssessmentSessionScheduledStartDateTime TEXT, -- Scheduled start date and time
    AssessmentSessionScheduledEndDateTime TEXT, -- Scheduled end date and time
    AssessmentSessionActualStartDateTime TEXT, -- Actual start date and time
    AssessmentSessionActualEndDateTime TEXT, -- Actual end date and time
    AssessmentSessionSecurityIssue TEXT, -- Description of security issues
    AssessmentSessionSpecialCircumstanceType TEXT CHECK (AssessmentSessionSpecialCircumstanceType IN (
        '13807', -- Long-term suspension - non-special education
        '13808', -- Short-term suspension - non-special education
        '13809', -- Suspension - special education
        '13810', -- Truancy - paperwork filed
        '13811', -- Truancy - no paperwork filed
        '13812', -- Earlier truancy
        '13813', -- Chronic absences
        '13814', -- Catastrophic illness or accident
        '13815', -- Home schooled for assessed subjects
        '13816', -- Student took this grade level assessment last year
        '13817', -- Incarcerated at adult facility
        '13818', -- Special treatment center
        '13819', -- Special detention center
        '13820', -- Parent refusal
        '13821', -- Cheating
        '13822', -- Psychological factors of emotional trauma
        '13823', -- Student not showing adequate effort
        '13824', -- Homebound
        '13825', -- Foreign exchange student
        '13826', -- Student refusal
        '13827', -- Reading passage read to student (IEP)
        '13828', -- Non-special education student used calculator on non-calculator items
        '13829', -- Student used math journal (non-IEP)
        '13830', -- Other reason for ineligibility
        '13831', -- Other reason for nonparticipation
        '13832', -- Left testing
        '13833', -- Cross-enrolled
        '13834', -- Only for writing
        '13835', -- Administration or system failure
        '13836', -- Teacher cheating or mis-admin
        '13837', -- Fire alarm
        '09999' -- Other
    )),
    AssessmentSessionSpecialEventDescription TEXT, -- Description of special events
    AssessmentSessionStaffRoleType TEXT CHECK (AssessmentSessionStaffRoleType IN (
        'Teacher', -- Teacher
        'Principal', -- Principal
        'Administrator', -- Administrator
        'Proctor', -- Proctor
        'Observer', -- Observer
        'Scorer', -- Scorer
        'Registrar' -- Registrar
    )),
    AssessmentSessionType TEXT CHECK (AssessmentSessionType IN (
        'Standard', -- Standard
        'Accommodation' -- Accommodation
    )),
    LocalEducationAgencyIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    LEAIdentificationSystem TEXT CHECK (LEAIdentificationSystem IN (
        'District', -- District-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'CENSUSID', -- Census Bureau identification code
        'OtherFederal', -- Other federally assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    )),
    SchoolIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    SchoolIdentificationSystem TEXT CHECK (SchoolIdentificationSystem IN (
        'School', -- School-assigned number
        'ACT', -- College Board/ACT program code set of PK-grade 12 institutions
        'LEA', -- Local Education Agency assigned number
        'SEA', -- State Education Agency assigned number
        'NCES', -- National Center for Education Statistics assigned number
        'Federal', -- Federal identification number
        'DUNS', -- Dun and Bradstreet number
        'OtherFederal', -- Other federally assigned number
        'StateUniversitySystem', -- State University System assigned number
        'Other', -- Other
        'SAM' -- System for Award Management Unique Entity Identifier
    ))
);

-- Creating table for Assessment Subtest entity
CREATE TABLE AssessmentSubtest (
    AssessmentSubtestIdentifier TEXT NOT NULL, -- Unique identifier, follows XSD:Token format
    AssessmentSubtestIdentifierType TEXT CHECK (AssessmentSubtestIdentifierType IN (
        'Client', -- Client
        'Publisher', -- Publisher
        'Internal', -- Internal
        'Other' -- Other
    )),
    AssessmentSubtestTitle TEXT, -- Name or title of the subtest
    AssessmentSubtestAbbreviation TEXT, -- Shortened name for reference
    AssessmentSubtestDescription TEXT, -- Description of the subtest
    AssessmentSubtestVersion TEXT, -- Version of the subtest
    AssessmentSubtestMinimumValue REAL, -- Minimum value possible
    AssessmentSubtestMaximumValue REAL, -- Maximum value possible
    AssessmentSubtestScaleOptimalValue REAL, -- Optimal value for measurement
    AssessmentSubtestPublishedDate DATE, -- Date subtest was published
    AssessmentSubtestRules TEXT, -- Rules for producing subtest score
    AssessmentAcademicSubject TEXT CHECK (AssessmentAcademicSubject IN (
        '13371', -- Arts
        '73065', -- Career and Technical Education
        '13372', -- English
        '00256', -- English as a second language (ESL)
        '00546', -- Foreign Languages
        '73088', -- History Government - US
        '73089', -- History Government - World
        '00554', -- Language arts
        '01166', -- Mathematics
        '00560', -- Reading
        '13373', -- Reading/Language Arts
        '00562', -- Science
        '73086', -- Science - Life
        '73087', -- Science - Physical
        '13374', -- Social Sciences (History, Geography, Economics, Civics and Government)
        '02043', -- Special education
        '01287', -- Writing
        '09999' -- Other
    )),
    AssessmentContentStandardType TEXT CHECK (AssessmentContentStandardType IN (
        'AssociationStandard', -- Association standard
        'LocalStandard', -- Local standard
        'None', -- None
        'Other', -- Other
        'OtherStandard', -- Other standard
        'RegionalStandard', -- Regional standard
        'SchoolStandard', -- School standard
        'StatewideStandard' -- Statewide standard
    )),
    AssessmentEarlyLearningDevelopmentalDomain TEXT CHECK (AssessmentEarlyLearningDevelopmentalDomain IN (
        '01', -- Language and Literacy
        '02', -- Cognition and General Knowledge
        '03', -- Approaches Toward Learning
        '04', -- Physical Well-being and Motor
        '05' -- Social and Emotional Development
    )),
    AssessmentFormSubtestContainerOnly TEXT CHECK (AssessmentFormSubtestContainerOnly IN ('Yes', 'No')),
    AssessmentFormSubtestTier INTEGER, -- Level in subtest hierarchy, default 0
    AssessmentLevelForWhichDesigned TEXT CHECK (AssessmentLevelForWhichDesigned IN (
        'Birth', -- Birth
        'Prenatal', -- Prenatal
        'IT', -- Infant/toddler
        'PR', -- Preschool
        'PK', -- Prekindergarten
        'TK', -- Transitional Kindergarten
        'KG', -- Kindergarten
        '01', -- First grade
        '02', -- Second grade
        '03', -- Third grade
        '04', -- Fourth grade
        '05', -- Fifth grade
        '06', -- Sixth grade
        '07', -- Seventh grade
        '08', -- Eighth grade
        '09', -- Ninth grade
        '10', -- Tenth grade
        '11', -- Eleventh grade
        '12', -- Twelfth grade
        '13', -- Grade 13
        'PS', -- Postsecondary
        'UG', -- Ungraded
        'AE', -- Adult Education
        'Other' -- Other
    )),
    AssessmentPurpose TEXT CHECK (AssessmentPurpose IN (
        '00050', -- Admission
        '00051', -- Assessment of student's progress
        '73055', -- College Readiness
        '00063', -- Course credit
        '00064', -- Course requirement
        '73069', -- Diagnosis
        '03459', -- Federal accountability
        '73068', -- Inform local or state policy
        '00055', -- Instructional decision
        '03457', -- Local accountability
        '02400', -- Local graduation requirement
        '73042', -- Obtain a state- or industry-recognized certificate or license
        '73043', -- Obtain postsecondary credit for the course
        '73067', -- Program eligibility
        '00057', -- Program evaluation
        '00058', -- Program placement
        '00062', -- Promotion to or retention in a grade or program
        '00061', -- Screening
        '03458', -- State accountability
        '09999', -- Other
        '00054' -- State graduation requirement
    )),
    AssessmentScoreMetricType TEXT CHECK (AssessmentScoreMetricType IN (
        '00512', -- Achievement/proficiency level
        '00494', -- ACT score
        '00490', -- Age score
        '00491', -- C-scaled scores
        '00492', -- College Board examination scores
        '00493', -- Grade equivalent or grade-level indicator
        '03473', -- Graduation score
        '03474', -- Growth/value-added/indexing
        '03475', -- International Baccalaureate score
        '00144', -- Letter grade/mark
        '00513', -- Mastery level
        '00497', -- Normal curve equivalent
        '00498', -- Normalized standard score
        '00499', -- Number score
        '00500', -- Pass-fail
        '03476', -- Percentile
        '00502', -- Percentile rank
        '00503', -- Proficiency level
        '03477', -- Promotion score
        '00504', -- Ranking
        '00505', -- Ratio IQ's
        '03478', -- Raw score
        '03479', -- Scale score
        '00506', -- Standard age score
        '00508', -- Stanine score
        '00509', -- Sten score
        '00510', -- T-score
        '03480', -- Workplace readiness score
        '00511', -- Z-score
        '03481', -- SAT Score
        '09999' -- Other
    ))
);

-- Creating table for Goal entity
CREATE TABLE Goal (
    GoalDescription TEXT, -- Description of desired outcomes
    GoalSuccessCriteria TEXT, -- Criteria for goal attainment
    GoalStartDate DATE, -- Date goal becomes active
    GoalEndDate DATE -- Date goal expires or is achieved
);

-- Creating table for Learner Action entity
CREATE TABLE LearnerAction (
    LearnerActionActorIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    LearnerActionDateTime TEXT, -- Date and time of action
    LearnerActionType TEXT CHECK (LearnerActionType IN (
        'abandoned', -- Abandoned
        'answered', -- Answered
        'asked', -- Asked
        'attempted', -- Attempted
        'attended', -- Attended
        'commented', -- Commented
        'completed', -- Completed
        'exited', -- Exited
        'experienced', -- Experienced
        'failed', -- Failed
        'imported', -- Imported
        'initialized', -- Initialized
        'interacted', -- Interacted
        'launched', -- Launched
        'logged-in', -- Logged-In
        'logged-out', -- Logged-Out
        'mastered', -- Mastered
        'passed', -- Passed
        'preferred', -- Preferred
        'progressed', -- Progressed
        'registered', -- Registered
        'responded', -- Responded
        'resumed', -- Resumed
        'satisfied', -- Satisfied
        'scored', -- Scored
        'shared', -- Shared
        'suspended', -- Suspended
        'terminated', -- Terminated
        'voided', -- Voided
        'waived' -- Waived
    )),
    LearnerActionValue TEXT, -- Input value or URL
    LearnerActionObjectDescription TEXT, -- Description of action object
    LearnerActionObjectIdentifier TEXT, -- Unique identifier or URL
    LearnerActionObjectType TEXT -- Type of action object
);

-- Creating table for Learner Activity entity
CREATE TABLE LearnerActivity (
    LearnerActivityTitle TEXT, -- Title of assigned work
    LearnerActivityDescription TEXT, -- Description for learner
    LearnerActivityType TEXT CHECK (LearnerActivityType IN (
        'Assignment', -- Assignment
        'LearningResource', -- Learning Resource
        'Activity', -- Activity
        'Lesson' -- Lesson
    )),
    LearnerActivityPrerequisite TEXT, -- Required skills or competencies
    LearnerActivityCreationDate DATE, -- Creation date
    LearnerActivityMaximumTimeAllowed REAL, -- Time to complete
    LearnerActivityMaximumTimeAllowedUnit TEXT CHECK (LearnerActivityMaximumTimeAllowedUnit IN (
        'Week', -- Week
        'Day', -- Day
        'Hour', -- Hour
        'Minute', -- Minute
        'Second' -- Second
    )),
    LearnerActivityDueDate DATE, -- Due date
    LearnerActivityDueTime TEXT, -- Due time
    LearnerActivityMaximumAttemptsAllowed INTEGER, -- Number of allowed attempts
    LearnerActivityAddToGradeBookFlag TEXT CHECK (LearnerActivityAddToGradeBookFlag IN (
        'Yes', -- Yes
        'No', -- No
        'NotSelected' -- Not selected
    )),
    LearnerActivityReleaseDate DATE, -- Date assignment is displayed
    LearnerActivityWeight REAL, -- Percentage weight
    LearnerActivityPossiblePoints REAL, -- Possible points
    LearnerActivityRubricURL TEXT, -- URL to rubric
    LearnerActivityLanguage TEXT -- ISO 639-2 language code, see http://www.loc.gov/standards/iso639-2/langhome.html
);

-- Creating table for Rubric entity
CREATE TABLE Rubric (
    AssessmentRubricIdentifier TEXT, -- Unique identifier, follows XSD:Token format
    AssessmentRubricTitle TEXT, -- Title of the rubric
    RubricDescription TEXT, -- Intended use of the rubric
    AssessmentRubricURLReference TEXT, -- URL location of rubric
    RubricCriterionCategory TEXT, -- Category for grouping criteria
    RubricCriterionDescription TEXT, -- Description of quality criterion
    RubricCriterionTitle TEXT, -- Title of criterion
    RubricCriterionPosition INTEGER, -- Position in criteria list
    RubricCriterionWeight REAL, -- Weight for scored rubrics
    RubricCriterionLevelDescription TEXT, -- Benchmarks for achievement
    RubricCriterionLevelFeedback TEXT, -- Feedback for evaluated person
    RubricCriterionLevelPosition INTEGER, -- Position in level list
    RubricCriterionLevelQualityLabel TEXT, -- Qualitative description
    RubricCriterionLevelScore REAL -- Points for achieving level
);

-- Creating table for Authentication Identity Provider entity
CREATE TABLE AuthenticationIdentityProvider (
    AuthenticationIdentityProviderName TEXT NOT NULL, -- Name of the provider that can authenticate identity
    AuthenticationIdentityProviderURI TEXT, -- URI of the Authentication Identity Provider
    AuthenticationIdentityProviderLoginIdentifier TEXT, -- Login identifier for the person, follows XSD:Token format, may be UUID
    AuthenticationIdentityProviderStartDate DATE, -- Date when person may begin using the provider
    AuthenticationIdentityProviderEndDate DATE -- Last date person is allowed to use the provider
);

-- Creating table for Authorization Application entity
CREATE TABLE AuthorizationApplication (
    AuthorizationApplicationName TEXT NOT NULL, -- Name of the data system or application
    AuthorizationApplicationURI TEXT, -- URI of the application
    AuthorizationApplicationRoleName TEXT, -- User role for which the person is allowed
    AuthorizationStartDate DATE, -- Date when person is authorized to start using the application
    AuthorizationEndDate DATE -- Last date person is allowed to use the application with the specified role
);
