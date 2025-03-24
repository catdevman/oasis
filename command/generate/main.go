package main

import (
	"database/sql"
	"fmt"
	"math/rand"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	_ "modernc.org/sqlite"
)

func main() {
	// Open SQLite database
	db, err := sql.Open("sqlite", "oasis.db")
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Enable foreign keys
	_, err = db.Exec("PRAGMA foreign_keys = ON;")
	if err != nil {
		panic(err)
	}

	// Insert Organization (1 district)
	_, err = db.Exec(`INSERT INTO Organization (Name, OrganizationType, Identifier, Address, City, StateCode, PostalCode) 
		VALUES (?, ?, ?, ?, ?, ?, ?)`, "Central District", "District", "DIST-002", "456 Elm St", "Central City", "TX", "75001")
	if err != nil {
		panic(err)
	}

	// Insert 5 Schools
	schools := []struct {
		id                     int
		name, category, grades string
	}{
		{1, "Central Elem 1", "Elementary", "KG-05"}, {2, "Central Elem 2", "Elementary", "KG-05"},
		{3, "Central Middle 1", "Middle", "06-08"}, {4, "Central Middle 2", "Middle", "06-08"},
		{5, "Central High", "High School", "09-12"},
	}
	for _, s := range schools {
		_, err = db.Exec(`INSERT INTO School (SchoolId, OrganizationId, SchoolCategory, GradeLevelsOffered, OperationalStatus) 
			VALUES (?, ?, ?, ?, ?)`, s.id, 1, s.category, s.grades, "Open")
		if err != nil {
			panic(err)
		}
	}

	// Insert Persons (3000 students, 4500 parents, 150 teachers)
	personId := 1
	for i := 0; i < 3000; i++ { // Students
		birthDate := gofakeit.DateRange(time.Now().AddDate(-15, 0, 0), time.Now().AddDate(-5, 0, 0))
		_, err = db.Exec(`INSERT INTO Person (PersonId, FirstName, LastName, BirthDate, Sex, Identifier) 
			VALUES (?, ?, ?, ?, ?, ?)`, personId, gofakeit.FirstName(), gofakeit.LastName(), birthDate.Format("2006-01-02"),
			gofakeit.RandomString([]string{"Male", "Female"}), fmt.Sprintf("STU-%04d", 1000+i))
		if err != nil {
			panic(err)
		}
		personId++
	}
	for i := 0; i < 4500; i++ { // Parents
		birthDate := gofakeit.DateRange(time.Now().AddDate(-50, 0, 0), time.Now().AddDate(-25, 0, 0))
		_, err = db.Exec(`INSERT INTO Person (PersonId, FirstName, LastName, BirthDate, Sex, Identifier) 
			VALUES (?, ?, ?, ?, ?, ?)`, personId, gofakeit.FirstName(), gofakeit.LastName(), birthDate.Format("2006-01-02"),
			gofakeit.RandomString([]string{"Male", "Female"}), fmt.Sprintf("PAR-%04d", 2000+i))
		if err != nil {
			panic(err)
		}
		personId++
	}

	for i := 0; i < 150; i++ { // Teachers
		birthDate := gofakeit.DateRange(time.Now().AddDate(-60, 0, 0), time.Now().AddDate(-25, 0, 0))
		_, err = db.Exec(`INSERT INTO Person (PersonId, FirstName, LastName, BirthDate, Sex, Identifier) 
			VALUES (?, ?, ?, ?, ?, ?)`, personId, gofakeit.FirstName(), gofakeit.LastName(), birthDate.Format("2006-01-02"),
			gofakeit.RandomString([]string{"Male", "Female"}), fmt.Sprintf("STA-%04d", 3000+i))
		if err != nil {
			panic(err)
		}
		personId++
	}

	// Insert Student
	grades := []string{"KG", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
	for i := 1; i <= 3000; i++ {
		grade := gofakeit.RandomString(grades)
		_, err = db.Exec(`INSERT INTO Student (StudentId, PersonId, GradeLevel, EnrollmentStatus, DisabilityStatus, EnglishProficiency) 
			VALUES (?, ?, ?, ?, ?, ?)`, i, i, grade, "Active", gofakeit.RandomString([]string{"Yes", "No"}),
			gofakeit.RandomString([]string{"Fluent", "ELL"}))
		if err != nil {
			panic(err)
		}
	}

	// Insert ParentGuardian
	for i := 1; i <= 4500; i++ {
		_, err = db.Exec(`INSERT INTO ParentGuardian (ParentGuardianId, PersonId, RelationshipType, EmergencyContactPriority) 
			VALUES (?, ?, ?, ?)`, i, 3000+i, gofakeit.RandomString([]string{"Mother", "Father", "Guardian"}), rand.Intn(2)+1)
		if err != nil {
			panic(err)
		}
	}

	// Insert StudentParent (1-2 parents per student)
	for studentId := 1; studentId <= 3000; studentId++ {
		numParents := rand.Intn(2) + 1
		parentIds := randomSample(1, 4500, numParents)
		for _, parentId := range parentIds {
			_, err = db.Exec(`INSERT INTO StudentParent (StudentId, ParentGuardianId) VALUES (?, ?)`, studentId, parentId)
			if err != nil {
				panic(err)
			}
		}
	}

	// Insert Staff
	for i := 1; i <= 150; i++ {
		hireDate := gofakeit.DateRange(time.Now().AddDate(-20, 0, 0), time.Now())
		_, err = db.Exec(`INSERT INTO Staff (StaffId, PersonId, PositionTitle, HireDate, EmploymentStatus) 
			VALUES (?, ?, ?, ?, ?)`, i, 7500+i, "Teacher", hireDate.Format("2006-01-02"), "Full-time")
		if err != nil {
			panic(err)
		}
	}

	// Insert Course (50 courses)
	courses := make([]struct{ code, title, desc, subject string }, 0, 50)
	for i := 1; i <= 12; i++ {
		courses = append(courses, struct{ code, title, desc, subject string }{fmt.Sprintf("MATH-%02d", i), fmt.Sprintf("Math Grade %d", i), "Math course", "Math"})
		courses = append(courses, struct{ code, title, desc, subject string }{fmt.Sprintf("ENG-%02d", i), fmt.Sprintf("English Grade %d", i), "English course", "English"})
		courses = append(courses, struct{ code, title, desc, subject string }{fmt.Sprintf("SCI-%02d", i), fmt.Sprintf("Science Grade %d", i), "Science course", "Science"})
		courses = append(courses, struct{ code, title, desc, subject string }{fmt.Sprintf("HIST-%02d", i), fmt.Sprintf("History Grade %d", i), "History course", "History"})
	}
	courses = append(courses, struct{ code, title, desc, subject string }{"PE-01", "Physical Education", "PE course", "PE"})
	courses = append(courses, struct{ code, title, desc, subject string }{"ART-01", "Art", "Art course", "Art"})
	for i, c := range courses {
		_, err = db.Exec(`INSERT INTO Course (CourseId, CourseCode, CourseTitle, Description, Subject) 
			VALUES (?, ?, ?, ?, ?)`, i+1, c.code, c.title, c.desc, c.subject)
		if err != nil {
			panic(err)
		}
	}

	// Insert CourseSection (300 sections)
	sectionId := 1
	for courseId := 1; courseId <= 50; courseId++ {
		numSections := rand.Intn(5) + 4 // 4-8 sections per course
		for j := 0; j < numSections; j++ {
			schoolId := rand.Intn(5) + 1
			staffId := rand.Intn(150) + 1
			_, err = db.Exec(`INSERT INTO CourseSection (SectionId, CourseId, SchoolId, SectionIdentifier, StaffId, SchoolYear, Period) 
				VALUES (?, ?, ?, ?, ?, ?, ?)`, sectionId, courseId, schoolId, fmt.Sprintf("%s-%c", courses[courseId-1].code, 'A'+j),
				staffId, "2024-2025", fmt.Sprintf("Period %d", rand.Intn(6)+1))
			if err != nil {
				panic(err)
			}
			sectionId++
		}
	}

	// Insert StudentEnrollment
	for studentId := 1; studentId <= 3000; studentId++ {
		var grade string
		err = db.QueryRow("SELECT GradeLevel FROM Student WHERE StudentId = ?", studentId).Scan(&grade)
		if err != nil {
			panic(err)
		}
		schoolId := 1
		if grade >= "06" && grade <= "08" {
			schoolId = 3
		} else if grade >= "09" && grade <= "12" {
			schoolId = 5
		}
		_, err = db.Exec(`INSERT INTO StudentEnrollment (StudentId, SchoolId, EntryDate, ExitDate, SchoolYear) 
			VALUES (?, ?, ?, ?, ?)`, studentId, schoolId, "2024-08-15", nil, "2024-2025")
		if err != nil {
			panic(err)
		}
	}

	// Insert StudentCourseSection
	for studentId := 1; studentId <= 3000; studentId++ {
		var schoolId int
		err = db.QueryRow("SELECT SchoolId FROM StudentEnrollment WHERE StudentId = ?", studentId).Scan(&schoolId)
		if err != nil {
			panic(err)
		}
		var grade string
		err = db.QueryRow("SELECT GradeLevel FROM Student WHERE StudentId = ?", studentId).Scan(&grade)
		if err != nil {
			panic(err)
		}
		rows, err := db.Query(`SELECT SectionId FROM CourseSection WHERE SchoolId = ? AND CourseId IN 
			(SELECT CourseId FROM Course WHERE CourseCode LIKE ?)`, schoolId, "%"+grade)
		if err != nil {
			panic(err)
		}
		defer rows.Close()
		var sectionIds []int
		for rows.Next() {
			var sid int
			if err := rows.Scan(&sid); err != nil {
				panic(err)
			}
			sectionIds = append(sectionIds, sid)
		}
		if len(sectionIds) > 0 {
			sectionId := sectionIds[rand.Intn(len(sectionIds))]
			_, err = db.Exec(`INSERT INTO StudentCourseSection (StudentId, SectionId, EnrollmentId, GradeEarned) 
				VALUES (?, ?, ?, ?)`, studentId, sectionId, studentId, gofakeit.RandomString([]string{"A", "A-", "B+", "B", "B-", "C+", "C", "C-"}))
			if err != nil {
				panic(err)
			}
		}
	}

	// Insert Incident (100 incidents)
	for i := 0; i < 100; i++ {
		schoolId := rand.Intn(5) + 1
		incidentDate := gofakeit.DateRange(time.Now().AddDate(0, -6, 0), time.Now())
		_, err = db.Exec(`INSERT INTO Incident (SchoolId, IncidentDate, IncidentType, Description) 
			VALUES (?, ?, ?, ?)`, schoolId, incidentDate.Format("2006-01-02"), gofakeit.RandomString([]string{"Disciplinary", "Safety"}),
			gofakeit.Sentence(5))
		if err != nil {
			panic(err)
		}
	}

	// Insert StudentIncident
	for incidentId := 1; incidentId <= 100; incidentId++ {
		var schoolId int
		err = db.QueryRow("SELECT SchoolId FROM Incident WHERE IncidentId = ?", incidentId).Scan(&schoolId)
		if err != nil {
			panic(err)
		}
		numStudents := rand.Intn(5) + 1
		rows, err := db.Query("SELECT StudentId FROM StudentEnrollment WHERE SchoolId = ?", schoolId)
		if err != nil {
			panic(err)
		}
		defer rows.Close()
		var studentIds []int
		for rows.Next() {
			var sid int
			if err := rows.Scan(&sid); err != nil {
				panic(err)
			}
			studentIds = append(studentIds, sid)
		}
		if len(studentIds) > 0 {
			selectedStudents := randomSampleFromSlice(studentIds, numStudents)
			for _, studentId := range selectedStudents {
				_, err = db.Exec(`INSERT INTO StudentIncident (StudentId, IncidentId, Role, ActionTaken) 
					VALUES (?, ?, ?, ?)`, studentId, incidentId, gofakeit.RandomString([]string{"Offender", "Victim", "Witness"}),
					gofakeit.RandomString([]string{"Detention", "Suspension", "Warning", "None", "First Aid"}))
				if err != nil {
					panic(err)
				}
			}
		}
	}

	fmt.Println("Data generation complete!")
}

// Helper function to generate random sample
func randomSample(min, max, count int) []int {
	if count > max-min+1 {
		count = max - min + 1
	}
	nums := make([]int, 0, count)
	used := make(map[int]bool)
	for len(nums) < count {
		n := rand.Intn(max-min+1) + min
		if !used[n] {
			nums = append(nums, n)
			used[n] = true
		}
	}
	return nums
}

// Helper function to sample from a slice
func randomSampleFromSlice(slice []int, count int) []int {
	if count > len(slice) {
		count = len(slice)
	}
	rand.Shuffle(len(slice), func(i, j int) { slice[i], slice[j] = slice[j], slice[i] })
	return slice[:count]
}
