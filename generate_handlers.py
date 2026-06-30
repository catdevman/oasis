import os
import re

domains = {
    "academicrecord": {"table": None},
    "assessment": {"table": "Assessment", "cols": ["AssessmentIdentifier", "AssessmentTitle"], "struct": "Assessment", "endpoint": "assessments"},
    "attendance": {"table": "CourseSectionAttendance", "cols": ["CourseSectionAttendanceIdentifier", "AttendanceEventCategory"], "struct": "Attendance", "endpoint": "attendances"},
    "bellschedule": {"table": None},
    "calendar": {"table": "Calendar", "cols": ["CalendarCode", "CalendarDescription", "SchoolYear"], "struct": "Calendar", "endpoint": "calendars"},
    "cohort": {"table": None},
    "coursecatalog": {"table": "CTECourse", "cols": ["CourseIdentifier", "CourseTitle"], "struct": "Course", "endpoint": "course-catalogs"},
    "credential": {"table": None},
    "discipline": {"table": None},
    "educationorg": {"table": "K12School", "cols": ["SchoolIdentifier", "NameOfInstitution"], "struct": "EducationOrg", "endpoint": "education-organizations"},
    "grades": {"table": None},
    "graduation": {"table": None},
    "intervention": {"table": None},
    "postsecondary": {"table": None},
    "program": {"table": "Program", "cols": ["ProgramIdentifier", "ProgramName"], "struct": "Program", "endpoint": "programs"},
    "section": {"table": "CourseSection", "cols": ["CourseSectionIdentifier", "CourseTitle"], "struct": "Section", "endpoint": "sections"},
    "staff": {"table": "K12Staff", "cols": ["StaffIdentifier", "FirstName", "LastOrSurname"], "struct": "Staff", "endpoint": "staffs"},
    "studentsection": {"table": "CourseSectionEnrollment", "cols": ["CourseSectionEnrollmentIdentifier", "StudentIdentifier"], "struct": "StudentSection", "endpoint": "student-section-associations"}
}

def write_repo(domain, info):
    repo_path = f"plugin/common/internal/{domain}/repository.go"
    if info["table"] is None:
        content = f"""package {domain}

import (
\t"database/sql"
)

type Repository struct {{
\tdb *sql.DB
}}

func NewRepository(db *sql.DB) *Repository {{
\treturn &Repository{{db: db}}
}}

func (r *Repository) List(limit, offset int) ([]interface{{}}, error) {{
\treturn []interface{{}}{{}}, nil
}}
"""
    else:
        struct_name = info["struct"]
        cols = info["cols"]
        table = info["table"]
        struct_fields = []
        scan_vars = []
        for i, col in enumerate(cols):
            struct_fields.append(f"\tField{i} string `json:\"{col.lower()}\"`")
            scan_vars.append(f"&s.Field{i}")
        
        cols_str = ", ".join(cols)
        scan_str = ", ".join(scan_vars)
        struct_body = "\\n".join(struct_fields)

        content = f"""package {domain}

import (
\t"database/sql"
)

type Repository struct {{
\tdb *sql.DB
}}

func NewRepository(db *sql.DB) *Repository {{
\treturn &Repository{{db: db}}
}}

type {struct_name} struct {{
{struct_body}
}}

func (r *Repository) List(limit, offset int) ([]{struct_name}, error) {{
\trows, err := r.db.Query("SELECT {cols_str} FROM {table} LIMIT $1 OFFSET $2", limit, offset)
\tif err != nil {{
\t\treturn nil, err
\t}}
\tdefer rows.Close()

\tvar items []{struct_name}
\tfor rows.Next() {{
\t\tvar s {struct_name}
\t\tif err := rows.Scan({scan_str}); err != nil {{
\t\t\treturn nil, err
\t\t}}
\t\titems = append(items, s)
\t}}
\treturn items, nil
}}
"""
    with open(repo_path, "w") as f:
        f.write(content)

def update_handler(domain, info):
    handler_path = f"plugin/common/internal/{domain}/handler.go"
    with open(handler_path, "r") as f:
        content = f.read()

    # Replace list method body
    # We find func (h *Handler) list(w http.ResponseWriter, r *http.Request) { ... }
    
    list_func = """func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
\tlimit := 50
\toffset := 0
\titems, err := h.repo.List(limit, offset)
\tif err != nil {
\t\tw.WriteHeader(http.StatusInternalServerError)
\t\tjson.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
\t\treturn
\t}
\tif items == nil {
\t\titems = make([]TYPE, 0) // or interface{} for empty ones
\t}
\tw.Header().Set("Content-Type", "application/json")
\tjson.NewEncoder(w).Encode(items)
}"""
    if info["table"] is None:
        list_func = list_func.replace("[]TYPE", "[]interface{}")
    else:
        list_func = list_func.replace("[]TYPE", f"[]{info['struct']}")
    
    # We need to replace the existing list function
    # The existing list function usually looks like:
    # func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
    # 	w.Header().Set("Content-Type", "application/json")
    # 	json.NewEncoder(w).Encode(map[string]string{"message": "..."})
    # }
    
    content = re.sub(r'func \(h \*Handler\) list\(w http\.ResponseWriter, r \*http\.Request\) \{.*?\}', list_func, content, flags=re.DOTALL)
    
    with open(handler_path, "w") as f:
        f.write(content)

for domain, info in domains.items():
    if os.path.exists(f"plugin/common/internal/{domain}"):
        write_repo(domain, info)
        update_handler(domain, info)

