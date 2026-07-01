//go:generate go run generate.go
package main

import (
	"bytes"
	"database/sql"
	"io"
	"net/http"
	"net/http/httptest"
	"sync"

	"github.com/catdevman/oasis/plugin/common/internal/academicrecord"
	"github.com/catdevman/oasis/plugin/common/internal/assessment"
	"github.com/catdevman/oasis/plugin/common/internal/attendance"
	"github.com/catdevman/oasis/plugin/common/internal/bellschedule"
	"github.com/catdevman/oasis/plugin/common/internal/calendar"
	"github.com/catdevman/oasis/plugin/common/internal/cohort"
	"github.com/catdevman/oasis/plugin/common/internal/coursecatalog"
	"github.com/catdevman/oasis/plugin/common/internal/credential"
	"github.com/catdevman/oasis/plugin/common/internal/discipline"
	"github.com/catdevman/oasis/plugin/common/internal/educationorg"
	"github.com/catdevman/oasis/plugin/common/internal/grades"
	"github.com/catdevman/oasis/plugin/common/internal/graduation"
	"github.com/catdevman/oasis/plugin/common/internal/intervention"
	"github.com/catdevman/oasis/plugin/common/internal/postsecondary"
	"github.com/catdevman/oasis/plugin/common/internal/program"
	"github.com/catdevman/oasis/plugin/common/internal/section"
	"github.com/catdevman/oasis/plugin/common/internal/staff"
	"github.com/catdevman/oasis/plugin/common/internal/student"
	"github.com/catdevman/oasis/plugin/common/internal/studentsection"
	"github.com/catdevman/oasis/shared"
)

type CommonPlugin struct {
	mux    *http.ServeMux
	db     *sql.DB
	dbOnce sync.Once
}

func New() *CommonPlugin {
	p := &CommonPlugin{
		mux: http.NewServeMux(),
	}
	p.dbOnce.Do(p.setupDatabase)

	// Register all 19 domains
	academicrecord.NewHandler(academicrecord.NewRepository(p.db)).Register(p.mux)
	assessment.NewHandler(assessment.NewRepository(p.db)).Register(p.mux)
	attendance.NewHandler(attendance.NewRepository(p.db)).Register(p.mux)
	bellschedule.NewHandler(bellschedule.NewRepository(p.db)).Register(p.mux)
	calendar.NewHandler(calendar.NewRepository(p.db)).Register(p.mux)
	cohort.NewHandler(cohort.NewRepository(p.db)).Register(p.mux)
	coursecatalog.NewHandler(coursecatalog.NewRepository(p.db)).Register(p.mux)
	credential.NewHandler(credential.NewRepository(p.db)).Register(p.mux)
	discipline.NewHandler(discipline.NewRepository(p.db)).Register(p.mux)
	educationorg.NewHandler(educationorg.NewRepository(p.db)).Register(p.mux)
	grades.NewHandler(grades.NewRepository(p.db)).Register(p.mux)
	graduation.NewHandler(graduation.NewRepository(p.db)).Register(p.mux)
	intervention.NewHandler(intervention.NewRepository(p.db)).Register(p.mux)
	postsecondary.NewHandler(postsecondary.NewRepository(p.db)).Register(p.mux)
	program.NewHandler(program.NewRepository(p.db)).Register(p.mux)
	section.NewHandler(section.NewRepository(p.db)).Register(p.mux)
	staff.NewHandler(staff.NewRepository(p.db)).Register(p.mux)
	student.NewHandler(student.NewRepository(p.db)).Register(p.mux)
	studentsection.NewHandler(studentsection.NewRepository(p.db)).Register(p.mux)

	return p
}

func (p *CommonPlugin) setupDatabase() {
	db, err := shared.OpenDatabase()
	if err != nil {
		panic("Failed to open database: " + err.Error())
	}
	p.db = db
}

func (p *CommonPlugin) ServeHTTP(req shared.HTTPRequest) (shared.HTTPResponse, error) {
	r, err := http.NewRequest(req.Method, req.URL, bytes.NewReader(req.Body))
	if err != nil {
		return shared.HTTPResponse{}, err
	}
	r.Header = req.Header

	w := httptest.NewRecorder()
	p.mux.ServeHTTP(w, r)

	resp := w.Result()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return shared.HTTPResponse{}, err
	}

	return shared.HTTPResponse{
		StatusCode: resp.StatusCode,
		Header:     resp.Header,
		Body:       body,
	}, nil
}
func (p *CommonPlugin) GetRoutes() ([]string, error) { return []string{}, nil }
func (p *CommonPlugin) GetMenuItems() ([]shared.MenuItem, error) { return nil, nil }
