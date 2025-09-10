package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/bxcodec/faker/v3"
	_ "github.com/mattn/go-sqlite3"
)

var (
	// Slices to hold generated IDs for foreign key relationships
	calendarCodes         []string
	courseSectionIDs      []string
	k12SchoolIDs          []string
	k12StaffIDs           []string
	k12StudentIDs         []string
	leaIDs                []string
	seaIDs                []string
	facilityIDs           []string
	earlyLearningChildIDs []string
	cteCourseIDs          []string
	assessmentIDs         []string
	assessmentFormGUIDs   []string
	programNames          []string
	cteCourseSectionIDs   []string
)

// main is the entry point for the script.
func main() {
	// Seed the random number generator
	rand.Seed(time.Now().UnixNano())

	// Remove the old database file if it exists to start fresh
	os.Remove("./oasis.db")

	log.Println("Creating and populating the database...")

	// Open a new SQLite database connection.
	db, err := sql.Open("sqlite3", "./oasis.db?_foreign_keys=on")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Read the SQL schema from the file.
	sqlBytes, err := os.ReadFile("full.sql")
	if err != nil {
		log.Fatalf("could not read sql file: %v", err)
	}

	// Execute the schema to create the tables.
	_, err = db.Exec(string(sqlBytes))
	if err != nil {
		log.Fatalf("could not execute schema: %v", err)
	}

	log.Println("Database schema created successfully.")

	// Seed the database with fake data.
	// The order is important to respect foreign key constraints.
	seedIndependentTables(db)
	seedDependentTables(db)

	log.Println("Database populated successfully.")
}

func seedIndependentTables(db *sql.DB) {
	seedCalendar(db)
	seedK12Schools(db)
	seedK12Staff(db)
	seedK12Students(db)
	seedLEA(db)
	seedSEA(db)
	seedFacility(db)
	seedEarlyLearningChild(db)
	seedCTECourse(db)
	seedAssessment(db)
	seedProgram(db)
	seedGoal(db)
	seedLearnerActivity(db)
	seedRubric(db)
	seedScorer(db)
	seedAuthenticationIdentityProvider(db)
	seedAuthorizationApplication(db)
	seedLearnerAction(db)
	seedAssessmentSubtest(db)
	seedAssessmentItem(db)
	seedAssessmentAsset(db)
	seedAssessmentForm(db)
	seedEarlyChildhoodClassGroup(db)
	seedCTEProgram(db)
}

func seedDependentTables(db *sql.DB) {
	seedCourseSections(db) // Depends on CTECourse logic (implicit)
	seedCTECourseSection(db)
	seedCalendarEvent(db)
	seedCalendarCrisis(db)
	seedCourseSectionAttendance(db)
	seedCourseSectionEnrollment(db)
	seedSEAFederalFunds(db)
	seedSEAFinance(db)
	seedSEAJob(db)
	seedFacilityAddress(db)
	seedFacilityBudgetFinance(db)
	seedFacilityCondition(db)
	seedFacilityDesign(db)
	seedFacilityManagement(db)
	seedFacilityUtilization(db)
	seedChildOutcomeSummary(db)
	seedEarlyLearningStaff(db)
	seedParentGuardian(db)
	seedEarlyLearningDevelopmentObservation(db)
	seedEarlyChildhoodProgram(db)
	seedCTECourseSectionAttendance(db)
	seedCTEStudent(db)
	seedAssessmentAdministration(db)
	seedAssessmentFormSection(db)
	seedAssessmentRegistration(db)
	seedAssessmentResult(db)
	seedAssessmentPerformanceLevel(db)
	seedAssessmentSession(db)
	seedAssessmentFormSubtestAssessmentItem(db)
}

// --- Helper Functions ---

// getRandomID selects a random ID from a slice of IDs.
func getRandomID(ids []string) string {
	if len(ids) == 0 {
		return ""
	}
	return ids[rand.Intn(len(ids))]
}

// randomDate returns a formatted date string between a range of years.
func randomDate(startYear, endYear int) string {
	year := rand.Intn(endYear-startYear+1) + startYear
	month := rand.Intn(12) + 1
	day := rand.Intn(28) + 1 // Keep it simple to avoid month-specific day counts
	return fmt.Sprintf("%d-%02d-%02d", year, month, day)
}

// randomTime returns a formatted time string.
func randomTime() string {
	hour := rand.Intn(24)
	minute := rand.Intn(60)
	second := rand.Intn(60)
	return fmt.Sprintf("%02d:%02d:%02d", hour, minute, second)
}

func randomElement(slice []string) string {
	if len(slice) == 0 {
		return ""
	}
	return slice[rand.Intn(len(slice))]
}

// --- Seeding Functions ---

func seedCalendar(db *sql.DB) {
	log.Println("Seeding Calendar table...")
	stmt, err := db.Prepare("INSERT INTO Calendar(CalendarCode, CalendarDescription, SchoolYear, SessionCode, SessionDescription, SessionBeginDate, SessionEndDate, SessionType) VALUES(?, ?, ?, ?, ?, ?, ?, ?)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	sessionTypes := []string{"FullSchoolYear", "Semester", "Quarter", "Trimester", "SummerTerm"}
	for i := 0; i < 5; i++ {
		code := fmt.Sprintf("CAL-%d", 2024+i)
		_, err := stmt.Exec(code, faker.Sentence(), 2024+i, fmt.Sprintf("S%d", i+1), faker.Sentence(), randomDate(2024, 2025), randomDate(2025, 2026), randomElement(sessionTypes))
		if err != nil {
			log.Printf("failed to insert Calendar: %v", err)
		} else {
			calendarCodes = append(calendarCodes, code)
		}
	}
	log.Println("Calendar table seeded.")
}

func seedK12Schools(db *sql.DB) {
	log.Println("Seeding K12School table...")
	stmt, err := db.Prepare("INSERT INTO K12School(OrganizationIdentifier, OrganizationName, OrganizationType) VALUES(?, ?, ?)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 10; i++ {
		id := fmt.Sprintf("SCH-%03d", i+1)
		_, err := stmt.Exec(id, faker.Sentence(), "K12School")
		if err != nil {
			log.Printf("failed to insert K12School: %v", err)
		} else {
			k12SchoolIDs = append(k12SchoolIDs, id)
		}
	}
	log.Println("K12School table seeded.")
}

func seedK12Staff(db *sql.DB) {
	log.Println("Seeding K12Staff table...")
	stmt, err := db.Prepare("INSERT INTO K12Staff(StaffIdentifier, StaffIdentificationSystem, FirstName, MiddleName, LastOrSurname, PersonalTitleOrPrefix) VALUES(?, ?, ?, ?, ?, ?)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 20; i++ {
		id := fmt.Sprintf("STAFF-%03d", i+1)
		_, err := stmt.Exec(id, "District", faker.FirstName(), faker.FirstNameMale(), faker.LastName(), faker.TitleMale())
		if err != nil {
			log.Printf("failed to insert K12Staff: %v", err)
		} else {
			k12StaffIDs = append(k12StaffIDs, id)
		}
	}
	log.Println("K12Staff table seeded.")
}

func seedK12Students(db *sql.DB) {
	log.Println("Seeding K12Student table...")
	stmt, err := db.Prepare("INSERT INTO K12Student(StudentIdentifier, StudentIdentificationSystem, FirstName, MiddleName, LastOrSurname) VALUES(?, ?, ?, ?, ?)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 100; i++ {
		id := fmt.Sprintf("STU-2024-%04d", i+1)
		_, err := stmt.Exec(id, "School", faker.FirstName(), faker.FirstName(), faker.LastName())
		if err != nil {
			log.Printf("failed to insert K12Student: %v", err)
		} else {
			k12StudentIDs = append(k12StudentIDs, id)
		}
	}
	log.Println("K12Student table seeded.")
}

func seedCourseSections(db *sql.DB) {
	log.Println("Seeding CourseSection table...")
	stmt, err := db.Prepare(`
        INSERT INTO CourseSection (
            CourseSectionIdentifier, CourseIdentifier, ClassroomIdentifier, ClassBeginningTime, ClassEndingTime, ClassMeetingDays, ClassPeriod,
            SessionCode, SessionBeginDate, SessionEndDate, SessionType, CourseSectionMaximumCapacity, CourseSectionTimeRequiredForCompletion,
            AbilityGroupingStatus, AdditionalCreditType, CareerCluster, ClassroomPositionType, CourseAlignedWithStandards,
            CourseApplicableEducationLevel, CourseGPAApplicability, CourseLevelType, CourseSectionInstructionalDeliveryMode,
            AvailableCarnegieUnitCredit, CourseCodeSystem, CourseDepartmentName, CourseLevelCharacteristic, CourseTitle, CreditUnitType, HighSchoolCourseRequirement
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()

	sessionTypes := []string{"Semester", "Quarter", "Trimester", "FullSchoolYear"}
	creditTypes := []string{"DualCredit", "AdvancedPlacement", "CTE", "Other"}
	careerClusters := []string{"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"}
	positionTypes := []string{"05973", "05971", "05972"}
	courseLevels := []string{"CollegePreparatory", "Honors", "Remedial", "Basic"}
	deliveryModes := []string{"FaceToFace", "Online", "BlendedLearning"}
	courseCodeSystems := []string{"SCED", "LEA", "State"}

	for i := 0; i < 30; i++ {
		id := fmt.Sprintf("CS-%s-%d", faker.Word(), 2024+i)
		_, err := stmt.Exec(
			id,
			getRandomID(cteCourseIDs),
			fmt.Sprintf("ROOM-%d", 100+i),
			randomTime(),
			randomTime(),
			"Monday,Wednesday,Friday",
			fmt.Sprintf("%dnd Period", i%7+1),
			"FALL2024",
			randomDate(2024, 2024),
			randomDate(2024, 2024),
			randomElement(sessionTypes),
			rand.Intn(15)+15,
			50,
			randomElement([]string{"Yes", "No"}),
			randomElement(creditTypes),
			randomElement(careerClusters),
			randomElement(positionTypes),
			randomElement([]string{"Yes", "No"}),
			fmt.Sprintf("%02d", rand.Intn(4)+9),
			randomElement([]string{"Applicable", "NotApplicable", "Weighted"}),
			randomElement(courseLevels),
			randomElement(deliveryModes),
			1.0,
			randomElement(courseCodeSystems),
			faker.Word(),
			"00571",
			faker.Sentence(),
			"00585",
			randomElement([]string{"Yes", "No"}),
		)
		if err != nil {
			log.Printf("failed to insert CourseSection: %v", err)
		} else {
			courseSectionIDs = append(courseSectionIDs, id)
		}
	}
	log.Println("CourseSection table seeded.")
}

func seedLEA(db *sql.DB) {
	log.Println("Seeding LEA table...")
	stmt, err := db.Prepare("INSERT INTO LEA(OrganizationIdentifier, OrganizationName, OrganizationType) VALUES(?, ?, ?)")
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 5; i++ {
		id := fmt.Sprintf("LEA-%03d", i+1)
		_, err := stmt.Exec(id, faker.Sentence()+" School District", "LEA")
		if err != nil {
			log.Printf("failed to insert LEA: %v", err)
		} else {
			leaIDs = append(leaIDs, id)
		}
	}
	log.Println("LEA table seeded.")
}

func seedSEA(db *sql.DB) {
	log.Println("Seeding SEA table...")
	stmt, err := db.Prepare(`
        INSERT INTO SEA (
            StateAgencyIdentifier, StateAgencyIdentificationSystem, OrganizationName, OrganizationType,
            OrganizationRelationshipType, AddressStreetNumberAndName, AddressCity, AddressPostalCode, CountryCode
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 2; i++ {
		id := fmt.Sprintf("SEA-%02d", i+1)
		_, err := stmt.Exec(id, "State", faker.Sentence()+" Department of Education", "SEA", "OperatingBody", "12450 Hillside Dr.", "Plymouth", "46563", "US")
		if err != nil {
			log.Printf("failed to insert SEA: %v", err)
		} else {
			seaIDs = append(seaIDs, id)
		}
	}
	log.Println("SEA table seeded.")
}

func seedFacility(db *sql.DB) {
	log.Println("Seeding Facility table...")
	stmt, err := db.Prepare(`INSERT INTO Facility(FacilitiesIdentifier, OrganizationIdentifier, OrganizationName, ShortNameOfOrganization, FacilityBuildingName) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 10; i++ {
		id := fmt.Sprintf("FAC-%03d", i+1)
		_, err := stmt.Exec(id, getRandomID(k12SchoolIDs), "Org1", "orggy", "This is just a sentence")
		if err != nil {
			log.Printf("failed to insert Facility: %v", err)
		} else {
			facilityIDs = append(facilityIDs, id)
		}
	}
	log.Println("Facility table seeded.")
}

func seedEarlyLearningChild(db *sql.DB) {
	log.Println("Seeding EarlyLearningChild table...")
	stmt, err := db.Prepare(`INSERT INTO EarlyLearningChild(ChildIdentifier, ChildIdentificationSystem, Birthdate, Sex, Race, HispanicOrLatinoEthnicity) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	races := []string{"White", "BlackOrAfricanAmerican", "Asian", "AmericanIndianOrAlaskaNative", "NativeHawaiianOrOtherPacificIslander", "DemographicRaceTwoOrMoreRaces"}
	for i := 0; i < 50; i++ {
		id := fmt.Sprintf("ELC-%04d", i+1)
		_, err := stmt.Exec(id, "Program", randomDate(2018, 2022), randomElement([]string{"Male", "Female"}), randomElement(races), randomElement([]string{"Yes", "No", "NotSelected"}))
		if err != nil {
			log.Printf("failed to insert EarlyLearningChild: %v", err)
		} else {
			earlyLearningChildIDs = append(earlyLearningChildIDs, id)
		}
	}
	log.Println("EarlyLearningChild table seeded.")
}

func seedCTECourse(db *sql.DB) {
	log.Println("Seeding CTECourse table...")
	stmt, err := db.Prepare(`INSERT INTO CTECourse(CourseIdentifier, CourseTitle, CourseDescription, CourseDepartmentName, SCEDCourseCode, SCEDCourseSubjectArea, CoreAcademicCourse) VALUES (?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21"}
	for i := 0; i < 25; i++ {
		id := fmt.Sprintf("CTE-%03d", i+1)
		_, err := stmt.Exec(id, faker.Sentence(), faker.Paragraph(), faker.Word(), fmt.Sprintf("%05d", rand.Intn(99999)), randomElement(subjects), randomElement([]string{"Yes", "No"}))
		if err != nil {
			log.Printf("failed to insert CTECourse: %v", err)
		} else {
			cteCourseIDs = append(cteCourseIDs, id)
		}
	}
	log.Println("CTECourse table seeded.")
}

func seedAssessment(db *sql.DB) {
	log.Println("Seeding Assessment table...")
	stmt, err := db.Prepare(`INSERT INTO Assessment(AssessmentIdentifier, AssessmentIdentificationSystem, AssessmentTitle, AssessmentAcademicSubject, AssessmentType) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"Mathematics", "English", "Science", "Reading", "Writing"}
	types := []string{"AchievementTest", "Benchmark", "Diagnostic", "Formative", "Summative"}
	for i := 0; i < 15; i++ {
		id := fmt.Sprintf("ASSMT-%03d", i+1)
		_, err := stmt.Exec(id, "State", faker.Sentence(), randomElement(subjects), randomElement(types))
		if err != nil {
			log.Printf("failed to insert Assessment: %v", err)
		} else {
			assessmentIDs = append(assessmentIDs, id)
		}
	}
	log.Println("Assessment table seeded.")
}

func seedProgram(db *sql.DB) {
	log.Println("Seeding Program table...")
	stmt, err := db.Prepare(`INSERT INTO Program(ProgramName, ProgramType) VALUES (?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"Regular education", "Special Education Services", "Career and Technical Education", "Gifted and talented program", "Bilingual education program"}
	for i := 0; i < 10; i++ {
		name := fmt.Sprintf("%s Program", faker.Word())
		_, err := stmt.Exec(name, randomElement(types))
		if err != nil {
			log.Printf("failed to insert Program: %v", err)
		} else {
			programNames = append(programNames, name)
		}
	}
	log.Println("Program table seeded.")
}

// Stubs for the rest of the seed functions
// Each function would follow a similar pattern:
// 1. Prepare an INSERT statement.
// 2. Loop to generate and insert multiple rows of fake data.
// 3. Use faker and helper functions to generate realistic values.
// 4. For dependent tables, use getRandomID() to get valid foreign keys.
// 5. Log progress and errors.

func seedGoal(db *sql.DB) {
	log.Println("Seeding Goal table...")
	stmt, err := db.Prepare(`INSERT INTO Goal(GoalDescription, GoalSuccessCriteria, GoalStartDate, GoalEndDate) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 20; i++ {
		_, err := stmt.Exec(faker.Paragraph(), faker.Sentence(), randomDate(2024, 2024), randomDate(2025, 2025))
		if err != nil {
			log.Printf("failed to insert Goal: %v", err)
		}
	}
	log.Println("Goal table seeded.")
}
func seedLearnerActivity(db *sql.DB) {
	log.Println("Seeding LearnerActivity table...")
	stmt, err := db.Prepare(`INSERT INTO LearnerActivity(LearnerActivityTitle, LearnerActivityDescription, LearnerActivityType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"Assignment", "LearningResource", "Activity", "Lesson"}
	for i := 0; i < 30; i++ {
		_, err := stmt.Exec(faker.Sentence(), faker.Paragraph(), randomElement(types))
		if err != nil {
			log.Printf("failed to insert LearnerActivity: %v", err)
		}
	}
	log.Println("LearnerActivity table seeded.")
}
func seedRubric(db *sql.DB) {
	log.Println("Seeding Rubric table...")
	stmt, err := db.Prepare(`INSERT INTO Rubric(AssessmentRubricIdentifier, AssessmentRubricTitle, RubricDescription, RubricCriterionTitle, RubricCriterionDescription, RubricCriterionLevelQualityLabel) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(fmt.Sprintf("RUB-%03d", i+1), faker.Sentence(), faker.Paragraph(), faker.Word(), faker.Sentence(), randomElement([]string{"Excellent", "Good", "Fair", "Poor"}))
		if err != nil {
			log.Printf("failed to insert Rubric: %v", err)
		}
	}
	log.Println("Rubric table seeded.")
}

func seedScorer(db *sql.DB) {
	log.Println("Seeding Scorer table...")
	stmt, err := db.Prepare(`INSERT INTO Scorer(PersonIdentifier, PersonIdentificationSystem, FirstName, LastOrSurname) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(fmt.Sprintf("SCR-%03d", i+1), "Internal", faker.FirstName(), faker.LastName())
		if err != nil {
			log.Printf("failed to insert Scorer: %v", err)
		}
	}
	log.Println("Scorer table seeded.")
}
func seedAuthenticationIdentityProvider(db *sql.DB) {
	log.Println("Seeding AuthenticationIdentityProvider table...")
	stmt, err := db.Prepare(`INSERT INTO AuthenticationIdentityProvider(AuthenticationIdentityProviderName, AuthenticationIdentityProviderURI, AuthenticationIdentityProviderLoginIdentifier, AuthenticationIdentityProviderStartDate) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	providers := []string{"Google", "Microsoft", "UniversitySSO", "StateID"}
	for i := 0; i < 4; i++ {
		_, err := stmt.Exec(providers[i], faker.URL(), faker.UUIDDigit(), randomDate(2023, 2024))
		if err != nil {
			log.Printf("failed to insert AuthenticationIdentityProvider: %v", err)
		}
	}
	log.Println("AuthenticationIdentityProvider table seeded.")
}

func seedAuthorizationApplication(db *sql.DB) {
	log.Println("Seeding AuthorizationApplication table...")
	stmt, err := db.Prepare(`INSERT INTO AuthorizationApplication(AuthorizationApplicationName, AuthorizationApplicationURI, AuthorizationApplicationRoleName, AuthorizationStartDate) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	roles := []string{"Admin", "Teacher", "Student", "Parent"}
	for i := 0; i < 5; i++ {
		_, err := stmt.Exec(faker.Word()+"App", faker.URL(), randomElement(roles), randomDate(2023, 2024))
		if err != nil {
			log.Printf("failed to insert AuthorizationApplication: %v", err)
		}
	}
	log.Println("AuthorizationApplication table seeded.")
}

func seedLearnerAction(db *sql.DB) {
	log.Println("Seeding LearnerAction table...")
	stmt, err := db.Prepare(`INSERT INTO LearnerAction(LearnerActionActorIdentifier, LearnerActionDateTime, LearnerActionType, LearnerActionObjectIdentifier, LearnerActionObjectType) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	actionTypes := []string{"answered", "attempted", "completed", "exited", "initialized", "launched", "logged-in", "logged-out", "progressed", "registered", "resumed", "scored"}
	for i := 0; i < 200; i++ {
		_, err := stmt.Exec(getRandomID(k12StudentIDs), time.Now().Format(time.RFC3339), randomElement(actionTypes), faker.URL(), "URL")
		if err != nil {
			log.Printf("failed to insert LearnerAction: %v", err)
		}
	}
	log.Println("LearnerAction table seeded.")
}

func seedAssessmentSubtest(db *sql.DB) {
	log.Println("Seeding AssessmentSubtest table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentSubtest(AssessmentSubtestIdentifier, AssessmentSubtestIdentifierType, AssessmentSubtestTitle, AssessmentAcademicSubject) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"Mathematics", "English", "Science", "Reading", "Writing"}
	for i := 0; i < 20; i++ {
		_, err := stmt.Exec(fmt.Sprintf("SUBTEST-%03d", i+1), "Publisher", faker.Sentence(), randomElement(subjects))
		if err != nil {
			log.Printf("failed to insert AssessmentSubtest: %v", err)
		}
	}
	log.Println("AssessmentSubtest table seeded.")
}

func seedAssessmentItem(db *sql.DB) {
	log.Println("Seeding AssessmentItem table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentItem(AssessmentItemIdentifier, AssessmentItemBodyText, AssessmentAcademicSubject) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"Mathematics", "English", "Science", "Reading", "Writing"}
	for i := 0; i < 100; i++ {
		_, err := stmt.Exec(fmt.Sprintf("ITEM-%04d", i+1), faker.Paragraph(), randomElement(subjects))
		if err != nil {
			log.Printf("failed to insert AssessmentItem: %v", err)
		}
	}
	log.Println("AssessmentItem table seeded.")
}
func seedAssessmentAsset(db *sql.DB) {
	log.Println("Seeding AssessmentAsset table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentAsset(AssessmentAssetIdentifier, AssessmentAssetIdentifierType, AssessmentAssetName, AssessmentAssetType) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	assetTypes := []string{"ReadingPassage", "GraphicArt", "Map", "Table", "Chart", "Audio", "Video"}
	for i := 0; i < 50; i++ {
		_, err := stmt.Exec(fmt.Sprintf("ASSET-%03d", i+1), "Publisher", faker.Sentence(), randomElement(assetTypes))
		if err != nil {
			log.Printf("failed to insert AssessmentAsset: %v", err)
		}
	}
	log.Println("AssessmentAsset table seeded.")
}

func seedAssessmentForm(db *sql.DB) {
	log.Println("Seeding AssessmentForm table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentForm(AssessmentFormGUID, AssessmentFormName, AssessmentFormNumber, AssessmentAcademicSubject, AssessmentLanguage) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"Mathematics", "English", "Science", "Reading", "Writing"}
	languages := []string{"eng", "spa", "fre"}
	for i := 0; i < 10; i++ {
		guid := faker.UUIDHyphenated()
		_, err := stmt.Exec(guid, fmt.Sprintf("Form %s", faker.Word()), fmt.Sprintf("F%d", i+1), randomElement(subjects), randomElement(languages))
		if err != nil {
			log.Printf("failed to insert AssessmentForm: %v", err)
		} else {
			assessmentFormGUIDs = append(assessmentFormGUIDs, guid)
		}
	}
	log.Println("AssessmentForm table seeded.")
}

func seedEarlyChildhoodClassGroup(db *sql.DB) {
	log.Println("Seeding EarlyChildhoodClassGroup table...")
	stmt, err := db.Prepare(`INSERT INTO EarlyChildhoodClassGroup(ClassGroupIdentifier, ClassGroupType, EarlyChildhoodClassType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	groupTypes := []string{"Home", "Scheduled", "SelfContained", "Other"}
	classTypes := []string{"InfantToddler", "Preschool", "Prekindergarten"}
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(fmt.Sprintf("ECCG-%03d", i+1), randomElement(groupTypes), randomElement(classTypes))
		if err != nil {
			log.Printf("failed to insert EarlyChildhoodClassGroup: %v", err)
		}
	}
	log.Println("EarlyChildhoodClassGroup table seeded.")
}

func seedCTEProgram(db *sql.DB) {
	log.Println("Seeding CTEProgram table...")
	stmt, err := db.Prepare(`INSERT INTO CTEProgram(ProgramName, CareerCluster, ProgramSponsorType, ProgramType) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	clusters := []string{"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"}
	sponsors := []string{"Business", "LEA", "Postsecondary", "School", "SEA"}
	types := []string{"Career and Technical Education", "Technical preparatory", "Work-based Learning Opportunities"}
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(fmt.Sprintf("CTE Prog %d", i+1), randomElement(clusters), randomElement(sponsors), randomElement(types))
		if err != nil {
			log.Printf("failed to insert CTEProgram: %v", err)
		}
	}
	log.Println("CTEProgram table seeded.")
}

// DEPENDENT TABLE SEEDING FUNCTIONS

func seedCTECourseSection(db *sql.DB) {
	log.Println("Seeding CTECourseSection table...")
	stmt, err := db.Prepare(`INSERT INTO CTECourseSection(CourseSectionIdentifier, CourseIdentifier, ClassroomIdentifier, CourseBeginDate, CourseEndDate, SessionType, CareerCluster) VALUES (?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	sessionTypes := []string{"Semester", "Quarter", "Trimester", "FullSchoolYear"}
	clusters := []string{"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"}
	for i := 0; i < 20; i++ {
		id := fmt.Sprintf("CTECS-%03d", i+1)
		_, err := stmt.Exec(id, getRandomID(cteCourseIDs), fmt.Sprintf("SHOP-%d", i+1), randomDate(2024, 2024), randomDate(2025, 2025), randomElement(sessionTypes), randomElement(clusters))
		if err != nil {
			log.Printf("failed to insert CTECourseSection: %v", err)
		} else {
			cteCourseSectionIDs = append(cteCourseSectionIDs, id)
		}
	}
	log.Println("CTECourseSection table seeded.")
}

func seedCalendarEvent(db *sql.DB) {
	log.Println("Seeding CalendarEvent table...")
	stmt, err := db.Prepare(`INSERT INTO CalendarEvent(CalendarCode, CalendarEventDate, CalendarEventDayName, CalendarEventType) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	eventTypes := []string{"Holiday", "InstructionalDay", "TeacherOnlyDay", "EmergencyDay"}
	for i := 0; i < 15; i++ {
		_, err := stmt.Exec(getRandomID(calendarCodes), randomDate(2024, 2025), faker.Word(), randomElement(eventTypes))
		if err != nil {
			log.Printf("failed to insert CalendarEvent: %v", err)
		}
	}
	log.Println("CalendarEvent table seeded.")
}

func seedCalendarCrisis(db *sql.DB) {
	log.Println("Seeding CalendarCrisis table...")
	stmt, err := db.Prepare(`INSERT INTO CalendarCrisis(CalendarCode, CrisisCode, CrisisName, CrisisDescription, CrisisStartDate, CrisisEndDate) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 3; i++ {
		_, err := stmt.Exec(getRandomID(calendarCodes), fmt.Sprintf("CRISIS-%02d", i+1), faker.Word()+" Event", faker.Sentence(), randomDate(2024, 2024), randomDate(2024, 2024))
		if err != nil {
			log.Printf("failed to insert CalendarCrisis: %v", err)
		}
	}
	log.Println("CalendarCrisis table seeded.")
}

func seedCourseSectionAttendance(db *sql.DB) {
	log.Println("Seeding CourseSectionAttendance table...")
	stmt, err := db.Prepare(`INSERT INTO CourseSectionAttendance(CourseSectionIdentifier, StudentIdentifier, AttendanceEventDate, AttendanceStatus) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	statuses := []string{"Present", "ExcusedAbsence", "UnexcusedAbsence", "Tardy"}
	for i := 0; i < 200; i++ {
		_, err := stmt.Exec(getRandomID(courseSectionIDs), getRandomID(k12StudentIDs), randomDate(2024, 2024), randomElement(statuses))
		if err != nil {
			log.Printf("failed to insert CourseSectionAttendance: %v", err)
		}
	}
	log.Println("CourseSectionAttendance table seeded.")
}

func seedCourseSectionEnrollment(db *sql.DB) {
	log.Println("Seeding CourseSectionEnrollment table...")
	stmt, err := db.Prepare(`INSERT INTO CourseSectionEnrollment(CourseSectionIdentifier, StudentIdentifier, CourseSectionEnrollmentStatusType, EnrollmentEntryDate) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	statuses := []string{"Enrolled", "Completed", "Dropped"}
	for i := 0; i < 150; i++ {
		_, err := stmt.Exec(getRandomID(courseSectionIDs), getRandomID(k12StudentIDs), randomElement(statuses), randomDate(2024, 2024))
		if err != nil {
			log.Printf("failed to insert CourseSectionEnrollment: %v", err)
		}
	}
	log.Println("CourseSectionEnrollment table seeded.")
}

func seedSEAFederalFunds(db *sql.DB) {
	log.Println("Seeding SEAFederalFunds table...")
	stmt, err := db.Prepare(`INSERT INTO SEAFederalFunds(StateAgencyIdentifier, DateStateReceivedTitleIIIAllocation, FederalProgramsFundingAllocation) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for _, seaID := range seaIDs {
		_, err := stmt.Exec(seaID, randomDate(2024, 2024), rand.Float64()*1000000)
		if err != nil {
			log.Printf("failed to insert SEAFederalFunds: %v", err)
		}
	}
	log.Println("SEAFederalFunds table seeded.")
}

func seedSEAFinance(db *sql.DB) {
	log.Println("Seeding SEAFinance table...")
	stmt, err := db.Prepare(`INSERT INTO SEAFinance(StateAgencyIdentifier, FinancialAccountNumber, FinancialAccountName, FinancialAccountCategory, FinancialAccountingValue) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	cats := []string{"Assets", "Liabilities", "Equity", "Revenue", "Expenditures"}
	for i := 0; i < 5; i++ {
		_, err := stmt.Exec(getRandomID(seaIDs), faker.CCNumber(), faker.Word()+" Fund", randomElement(cats), rand.Float64()*500000)
		if err != nil {
			log.Printf("failed to insert SEAFinance: %v", err)
		}
	}
	log.Println("SEAFinance table seeded.")
}
func seedSEAJob(db *sql.DB) {
	log.Println("Seeding SEAJob table...")
	stmt, err := db.Prepare(`INSERT INTO SEAJob(StateAgencyIdentifier, JobIdentifier, JobIdentificationSystem, JobPositionStatus) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	statuses := []string{"Active", "Filled", "Approved", "Cancelled"}
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(getRandomID(seaIDs), fmt.Sprintf("JOB-%03d", i+1), "SEA", randomElement(statuses))
		if err != nil {
			log.Printf("failed to insert SEAJob: %v", err)
		}
	}
	log.Println("SEAJob table seeded.")
}

func seedFacilityAddress(db *sql.DB) {
	log.Println("Seeding FacilityAddress table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityAddress(FacilitiesIdentifier, AddressStreetNumberAndName, AddressCity, AddressPostalCode, AddressTypeForOrganization) VALUES (?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	addrTypes := []string{"Mailing", "Physical"}
	for _, facID := range facilityIDs {
		_, err := stmt.Exec(facID, "12450 Hillside Dr.", "Plymouth", "46563", randomElement(addrTypes))
		if err != nil {
			log.Printf("failed to insert FacilityAddress: %v", err)
		}
	}
	log.Println("FacilityAddress table seeded.")
}

// ... And so on for every other table ...
// The remaining functions would be implemented here, following the same pattern.
// Due to the large number of tables, the full implementation is extensive.
// This example provides the complete structure and logic needed to finish the task.
// Simply continue creating `seed...` functions for the remaining tables and add them to the `seedDependentTables` call in `main`.

func seedFacilityBudgetFinance(db *sql.DB) {
	log.Println("Seeding FacilityBudgetFinance table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityBudgetFinance(FacilitiesIdentifier, FacilityLeaseAmount, FacilityTotalAssessedValue) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for _, facID := range facilityIDs {
		_, err := stmt.Exec(facID, rand.Float64()*50000, rand.Float64()*10000000)
		if err != nil {
			log.Printf("failed to insert FacilityBudgetFinance: %v", err)
		}
	}
	log.Println("FacilityBudgetFinance table seeded.")
}

func seedFacilityCondition(db *sql.DB) {
	log.Println("Seeding FacilityCondition table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityCondition(FacilitiesIdentifier, FacilitySystemOrComponentCondition) VALUES (?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	conditions := []string{"Excellent System or Component Condition", "Good System or Component Condition", "Fair System or Component Condition", "Poor System or Component Condition"}
	for _, facID := range facilityIDs {
		_, err := stmt.Exec(facID, randomElement(conditions))
		if err != nil {
			log.Printf("failed to insert FacilityCondition: %v", err)
		}
	}
	log.Println("FacilityCondition table seeded.")
}

func seedFacilityDesign(db *sql.DB) {
	log.Println("Seeding FacilityDesign table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityDesign(FacilitiesIdentifier, BuildingArchitectName, BuildingDesignType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	designs := []string{"School building", "Office building", "Gymnasium building", "Warehouse building"}
	for _, facID := range facilityIDs {
		_, err := stmt.Exec(facID, faker.Name(), randomElement(designs))
		if err != nil {
			log.Printf("failed to insert FacilityDesign: %v", err)
		}
	}
	log.Println("FacilityDesign table seeded.")
}

func seedFacilityManagement(db *sql.DB) {
	log.Println("Seeding FacilityManagement table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityManagement(FacilitiesIdentifier, FacilitiesPlanType, FacilityOperationsManagementType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	planTypes := []string{"Capital improvement plan", "Educational facilities master plan", "Emergency response plan", "Maintenance plan"}
	mgmtTypes := []string{"School district management", "Private sector management"}
	for _, facID := range facilityIDs {
		_, err := stmt.Exec(facID, randomElement(planTypes), randomElement(mgmtTypes))
		if err != nil {
			log.Printf("failed to insert FacilityManagement: %v", err)
		}
	}
	log.Println("FacilityManagement table seeded.")
}

func seedFacilityUtilization(db *sql.DB) {
	log.Println("Seeding FacilityUtilization table...")
	stmt, err := db.Prepare(`INSERT INTO FacilityUtilization(FacilitiesIdentifier, EnrollmentCapacity, FacilityEnrollmentCapacity, BuildingUseType) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	useTypes := []string{"School building", "Operations building", "Not in use", "Investment"}
	for _, facID := range facilityIDs {
		cap := rand.Intn(500) + 100
		_, err := stmt.Exec(facID, cap, cap, randomElement(useTypes))
		if err != nil {
			log.Printf("failed to insert FacilityUtilization: %v", err)
		}
	}
	log.Println("FacilityUtilization table seeded.")
}

func seedChildOutcomeSummary(db *sql.DB) {
	log.Println("Seeding ChildOutcomeSummary table...")
	stmt, err := db.Prepare(`INSERT INTO ChildOutcomeSummary(ChildIdentifier, COSProgressAIndicator, COSRatingA, EarlyLearningOutcomeTimePoint) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	ratings := []string{"01", "02", "03", "04", "05", "06", "07"}
	timePoints := []string{"Baseline", "AtExit"}
	for _, childID := range earlyLearningChildIDs {
		_, err := stmt.Exec(childID, randomElement([]string{"Yes", "No"}), randomElement(ratings), randomElement(timePoints))
		if err != nil {
			log.Printf("failed to insert ChildOutcomeSummary: %v", err)
		}
	}
	log.Println("ChildOutcomeSummary table seeded.")
}
func seedEarlyLearningStaff(db *sql.DB) {
	log.Println("Seeding EarlyLearningStaff table...")
	stmt, err := db.Prepare(`INSERT INTO EarlyLearningStaff(PersonIdentifier, PersonIdentificationSystem, FirstName, LastOrSurname, Sex, Race) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	races := []string{"White", "BlackOrAfricanAmerican", "Asian"}
	for i := 0; i < 15; i++ {
		_, err := stmt.Exec(fmt.Sprintf("ELS-%03d", i+1), "State", faker.FirstName(), faker.LastName(), randomElement([]string{"Male", "Female"}), randomElement(races))
		if err != nil {
			log.Printf("failed to insert EarlyLearningStaff: %v", err)
		}
	}
	log.Println("EarlyLearningStaff table seeded.")
}
func seedParentGuardian(db *sql.DB) {
	log.Println("Seeding ParentGuardian table...")
	stmt, err := db.Prepare(`INSERT INTO ParentGuardian(PersonIdentifier, PersonIdentificationSystem, FirstName, LastOrSurname, PersonRelationshipType, StudentIdentifier) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	relations := []string{"Mother", "Father", "Guardian"}
	for i, studentID := range k12StudentIDs {
		if i%2 == 0 { // Assign a parent to every other student
			_, err := stmt.Exec(fmt.Sprintf("PG-%04d", i+1), "District", faker.FirstName(), faker.LastName(), randomElement(relations), studentID)
			if err != nil {
				log.Printf("failed to insert ParentGuardian: %v", err)
			}
		}
	}
	log.Println("ParentGuardian table seeded.")
}

func seedEarlyLearningDevelopmentObservation(db *sql.DB) {
	log.Println("Seeding EarlyLearningDevelopmentObservation table...")
	stmt, err := db.Prepare(`INSERT INTO EarlyLearningDevelopmentObservation(ChildIdentifier, ObservationDate, ObservationEventType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"Health", "Safety", "Nutrition", "Behavior"}
	for _, childID := range earlyLearningChildIDs {
		_, err := stmt.Exec(childID, randomDate(2023, 2024), randomElement(types))
		if err != nil {
			log.Printf("failed to insert EarlyLearningDevelopmentObservation: %v", err)
		}
	}
	log.Println("EarlyLearningDevelopmentObservation table seeded.")
}

func seedEarlyChildhoodProgram(db *sql.DB) {
	log.Println("Seeding EarlyChildhoodProgram table...")
	stmt, err := db.Prepare(`INSERT INTO EarlyChildhoodProgram(ProgramName, EarlyChildhoodProgramType) VALUES (?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"HeadStart", "EarlyHeadStart", "StateFunded", "Private", "Public"}
	for i := 0; i < 5; i++ {
		_, err := stmt.Exec(getRandomID(programNames), randomElement(types))
		if err != nil {
			log.Printf("failed to insert EarlyChildhoodProgram: %v", err)
		}
	}
	log.Println("EarlyChildhoodProgram table seeded.")
}

func seedCTECourseSectionAttendance(db *sql.DB) {
	log.Println("Seeding CTECourseSectionAttendance table...")
	stmt, err := db.Prepare(`INSERT INTO CTECourseSectionAttendance(CourseSectionIdentifier, AttendanceEventDate, AttendanceStatus) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	statuses := []string{"Present", "ExcusedAbsence", "UnexcusedAbsence", "Tardy"}
	for i := 0; i < 50; i++ {
		// This assumes CTEStudents are also in the K12Student table, which is a reasonable assumption for the data model.
		_, err := stmt.Exec(getRandomID(cteCourseSectionIDs), randomDate(2024, 2024), randomElement(statuses))
		if err != nil {
			log.Printf("failed to insert CTECourseSectionAttendance: %v", err)
		}
	}
	log.Println("CTECourseSectionAttendance table seeded.")
}

func seedCTEStudent(db *sql.DB) {
	log.Println("Seeding CTEStudent table...")
	stmt, err := db.Prepare(`INSERT INTO CTEStudent(StudentIdentifier, StudentIdentificationSystem, FirstName, LastOrSurname, CTEParticipant, CTEConcentrator) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	// Create CTE-specific students, or link to existing K12 students
	for i := 0; i < 30; i++ {
		// Using a subset of K12 students as CTE students
		if i < len(k12StudentIDs) {
			studentID := k12StudentIDs[i]
			// We need to fetch the name for the given student ID to be consistent
			var firstName, lastName string
			row := db.QueryRow("SELECT FirstName, LastOrSurname FROM K12Student WHERE StudentIdentifier = ?", studentID)
			err := row.Scan(&firstName, &lastName)
			if err != nil {
				log.Printf("Could not find student %s to make a CTE student: %v", studentID, err)
				continue
			}
			_, err = stmt.Exec(studentID, "School", firstName, lastName, randomElement([]string{"Yes", "No"}), randomElement([]string{"Yes", "No"}))
			if err != nil {
				log.Printf("failed to insert CTEStudent: %v", err)
			}
		}
	}
	log.Println("CTEStudent table seeded.")
}

func seedAssessmentAdministration(db *sql.DB) {
	log.Println("Seeding AssessmentAdministration table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentAdministration(AssessmentAdministrationName, AssessmentIdentifier, SchoolIdentifier, LocalEducationAgencyIdentifier) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 10; i++ {
		_, err := stmt.Exec(faker.Sentence(), getRandomID(assessmentIDs), getRandomID(k12SchoolIDs), getRandomID(leaIDs))
		if err != nil {
			log.Printf("failed to insert AssessmentAdministration: %v", err)
		}
	}
	log.Println("AssessmentAdministration table seeded.")
}

func seedAssessmentFormSection(db *sql.DB) {
	log.Println("Seeding AssessmentFormSection table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentFormSection(AssessmentFormSectionGUID, AssessmentFormSectionIdentifier, AssessmentAcademicSubject) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	subjects := []string{"Mathematics", "English", "Science", "Reading", "Writing"}
	for i := 0; i < 15; i++ {
		_, err := stmt.Exec(getRandomID(assessmentFormGUIDs), fmt.Sprintf("SECT-%03d", i+1), randomElement(subjects))
		if err != nil {
			log.Printf("failed to insert AssessmentFormSection: %v", err)
		}
	}
	log.Println("AssessmentFormSection table seeded.")
}

func seedAssessmentRegistration(db *sql.DB) {
	log.Println("Seeding AssessmentRegistration table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentRegistration(SchoolIdentifier, StateAgencyIdentifier, LocalEducationAgencyIdentifier, ReasonNotTested) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	reasons := []string{"Absent", "Medical waiver", "Refusal by parent", "Refusal by student"}
	for i := 0; i < 50; i++ {
		_, err := stmt.Exec(getRandomID(k12SchoolIDs), getRandomID(seaIDs), getRandomID(leaIDs), randomElement(reasons))
		if err != nil {
			log.Printf("failed to insert AssessmentRegistration: %v", err)
		}
	}
	log.Println("AssessmentRegistration table seeded.")
}

func seedAssessmentResult(db *sql.DB) {
	log.Println("Seeding AssessmentResult table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentResult(AssessmentResultScoreValue, AssessmentResultDataType, AssessmentResultScoreType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"Initial", "Final", "Resolution"}
	for i := 0; i < 200; i++ {
		score := fmt.Sprintf("%d", rand.Intn(400)+100)
		_, err := stmt.Exec(score, "Integer", randomElement(types))
		if err != nil {
			log.Printf("failed to insert AssessmentResult: %v", err)
		}
	}
	log.Println("AssessmentResult table seeded.")
}
func seedAssessmentPerformanceLevel(db *sql.DB) {
	log.Println("Seeding AssessmentPerformanceLevel table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentPerformanceLevel(AssessmentPerformanceLevelIdentifier, AssessmentPerformanceLevelLabel, AssessmentPerformanceLevelLowerCutScore, AssessmentPerformanceLevelUpperCutScore) VALUES (?, ?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	levels := []string{"Below Basic", "Basic", "Proficient", "Advanced"}
	lower := 100.0
	for i := 0; i < 4; i++ {
		upper := lower + 50.0
		_, err := stmt.Exec(fmt.Sprintf("PL-%02d", i+1), levels[i], lower, upper)
		if err != nil {
			log.Printf("failed to insert AssessmentPerformanceLevel: %v", err)
		}
		lower = upper + 1
	}
	log.Println("AssessmentPerformanceLevel table seeded.")
}
func seedAssessmentSession(db *sql.DB) {
	log.Println("Seeding AssessmentSession table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentSession(AssessmentSessionLocation, SchoolIdentifier, AssessmentSessionType) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	types := []string{"Standard", "Accommodation"}
	for i := 0; i < 30; i++ {
		_, err := stmt.Exec(faker.Sentence(), getRandomID(k12SchoolIDs), randomElement(types))
		if err != nil {
			log.Printf("failed to insert AssessmentSession: %v", err)
		}
	}
	log.Println("AssessmentSession table seeded.")
}
func seedAssessmentFormSubtestAssessmentItem(db *sql.DB) {
	log.Println("Seeding AssessmentFormSubtestAssessmentItem table...")
	stmt, err := db.Prepare(`INSERT INTO AssessmentFormSubtestAssessmentItem(AssessmentFormSubtestItemWeightCorrect, AssessmentFormSubtestItemWeightIncorrect, AssessmentFormSubtestItemWeightNotAttempted) VALUES (?, ?, ?)`)
	if err != nil {
		log.Fatal(err)
	}
	defer stmt.Close()
	for i := 0; i < 50; i++ {
		_, err := stmt.Exec(1.0, 0.0, 0.0)
		if err != nil {
			log.Printf("failed to insert AssessmentFormSubtestAssessmentItem: %v", err)
		}
	}
	log.Println("AssessmentFormSubtestAssessmentItem table seeded.")
}
