package main

import (
	"encoding/json"
	"embed"
	"fmt"
	"html/template"
	"net/http"
	"io"
	"strconv"

	"github.com/catdevman/oasis/shared"
)

//go:embed ui/*.html
var uiTemplates embed.FS

type UIHandler struct {
	tmpl *template.Template
}

func NewUIHandler() *UIHandler {
	tmpl := template.Must(template.ParseFS(uiTemplates, "ui/*.html"))
	return &UIHandler{
		tmpl: tmpl,
	}
}

type PaginatedData struct {
	Items      interface{}
	Pagination template.HTML
}

func (h *UIHandler) Register(mux *http.ServeMux) {
	mux.HandleFunc("GET /overview", h.handleOverview)
	mux.HandleFunc("GET /students", h.handleStudents)
	mux.HandleFunc("GET /staff", h.handleStaff)
	mux.HandleFunc("GET /schools", h.handleSchools)
	mux.HandleFunc("GET /sections", h.handleSections)
}

func (h *UIHandler) handleOverview(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`
	<div class="content-card">
		<h1 class="text-3xl font-semibold mb-6 tracking-tight text-gray-800">Welcome to Oasis</h1>
		<p class="text-gray-600 leading-relaxed max-w-2xl">
			Select a domain from the dynamically generated sidebar to view the data. 
			This layout is served by the host application, while the content is securely fetched via RPC from our Micro-Frontend plugins!
		</p>
	</div>
	`))
}

func fetchAPI(endpoint string, result interface{}) error {
	resp, err := http.Get("http://127.0.0.1:8080/api/common/ed-fi/" + endpoint)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	
	return json.Unmarshal(body, result)
}

func (h *UIHandler) renderTemplate(w http.ResponseWriter, name string, data interface{}) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`<div class="content-card">` + "\n"))
	err := h.tmpl.ExecuteTemplate(w, name, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Write([]byte("\n" + `</div>`))
}

func (h *UIHandler) handleStudents(w http.ResponseWriter, r *http.Request) {
	page := 1
	if p := r.URL.Query().Get("page"); p != "" {
		if parsed, err := strconv.Atoi(p); err == nil && parsed > 0 {
			page = parsed
		}
	}
	limit := 10
	offset := (page - 1) * limit

	var items []map[string]interface{}
	endpoint := fmt.Sprintf("students?limit=%d&offset=%d", limit+1, offset)
	err := fetchAPI(endpoint, &items)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	pagination := shared.NewPagination("/students", page, limit, &items)

	data := PaginatedData{
		Items:      items,
		Pagination: pagination.Render(),
	}

	h.renderTemplate(w, "students.html", data)
}

func (h *UIHandler) handleStaff(w http.ResponseWriter, r *http.Request) {
	var items []map[string]interface{}
	err := fetchAPI("staffs", &items)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	h.renderTemplate(w, "staff.html", items)
}

func (h *UIHandler) handleSchools(w http.ResponseWriter, r *http.Request) {
	var items []map[string]interface{}
	err := fetchAPI("education-organizations", &items)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	h.renderTemplate(w, "schools.html", items)
}

func (h *UIHandler) handleSections(w http.ResponseWriter, r *http.Request) {
	var items []map[string]interface{}
	err := fetchAPI("sections", &items)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	h.renderTemplate(w, "sections.html", items)
}
