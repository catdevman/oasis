package main

import (
	"database/sql"
	"embed"
	"html/template"
	"net/http"

	"github.com/catdevman/oasis/plugin/common/internal/educationorg"
	"github.com/catdevman/oasis/plugin/common/internal/section"
	"github.com/catdevman/oasis/plugin/common/internal/staff"
	"github.com/catdevman/oasis/plugin/common/internal/student"
)

//go:embed ui/*.html
var uiTemplates embed.FS

type UIHandler struct {
	db      *sql.DB
	tmpl    *template.Template
	student *student.Repository
	staff   *staff.Repository
	school  *educationorg.Repository
	section *section.Repository
}

func NewUIHandler(db *sql.DB) *UIHandler {
	tmpl := template.Must(template.ParseFS(uiTemplates, "ui/*.html"))
	return &UIHandler{
		db:      db,
		tmpl:    tmpl,
		student: student.NewRepository(db),
		staff:   staff.NewRepository(db),
		school:  educationorg.NewRepository(db),
		section: section.NewRepository(db),
	}
}

func (h *UIHandler) Register(mux *http.ServeMux) {
	mux.HandleFunc("GET /ui/dashboard", h.handleDashboard)
	mux.HandleFunc("GET /ui/overview", h.handleOverview)
	mux.HandleFunc("GET /ui/students", h.handleStudents)
	mux.HandleFunc("GET /ui/staff", h.handleStaff)
	mux.HandleFunc("GET /ui/schools", h.handleSchools)
	mux.HandleFunc("GET /ui/sections", h.handleSections)
}

func (h *UIHandler) handleDashboard(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	h.tmpl.ExecuteTemplate(w, "layout.html", nil)
}

func (h *UIHandler) handleOverview(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`
	<div class="glass-panel">
		<h1 class="page-title">Welcome to Oasis</h1>
		<p style="color: var(--text-muted); line-height: 1.6;">
			Select an Ed-Fi domain from the sidebar to view the data. 
			This dashboard is rendered entirely in Go using html/template and powered by HTMX for lightning fast, SPA-like navigation without a heavy JavaScript framework.
		</p>
	</div>
	`))
}

func (h *UIHandler) handleStudents(w http.ResponseWriter, r *http.Request) {
	items, err := h.student.List(50, 0)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	h.tmpl.ExecuteTemplate(w, "students.html", items)
}

func (h *UIHandler) handleStaff(w http.ResponseWriter, r *http.Request) {
	items, err := h.staff.List(50, 0)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	h.tmpl.ExecuteTemplate(w, "staff.html", items)
}

func (h *UIHandler) handleSchools(w http.ResponseWriter, r *http.Request) {
	items, err := h.school.List(50, 0)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	h.tmpl.ExecuteTemplate(w, "schools.html", items)
}

func (h *UIHandler) handleSections(w http.ResponseWriter, r *http.Request) {
	items, err := h.section.List(50, 0)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	h.tmpl.ExecuteTemplate(w, "sections.html", items)
}
