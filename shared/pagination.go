package shared

import (
	"bytes"
	"html/template"
)

type Pagination struct {
	BaseURL  string
	Page     int
	HasNext  bool
	HasPrev  bool
	NextPage int
	PrevPage int
}

var paginationTmpl = template.Must(template.New("pagination").Parse(`
    <div class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 mt-4 rounded-b-lg">
        <div class="flex flex-1 justify-between sm:hidden">
            {{if .HasPrev}}
            <a href="{{.BaseURL}}?page={{.PrevPage}}" hx-get="{{.BaseURL}}?page={{.PrevPage}}" hx-target="#main-content" hx-push-url="true" class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Previous</a>
            {{end}}
            {{if .HasNext}}
            <a href="{{.BaseURL}}?page={{.NextPage}}" hx-get="{{.BaseURL}}?page={{.NextPage}}" hx-target="#main-content" hx-push-url="true" class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Next</a>
            {{end}}
        </div>
        <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
            <div>
                <p class="text-sm text-gray-700">
                    Showing page <span class="font-medium">{{.Page}}</span>
                </p>
            </div>
            <div>
                <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                    {{if .HasPrev}}
                    <a href="{{.BaseURL}}?page={{.PrevPage}}" hx-get="{{.BaseURL}}?page={{.PrevPage}}" hx-target="#main-content" hx-push-url="true" class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                        <span class="sr-only">Previous</span>
                        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
                        </svg>
                    </a>
                    {{else}}
                    <span class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-200 cursor-not-allowed">
                        <span class="sr-only">Previous</span>
                        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
                        </svg>
                    </span>
                    {{end}}

                    {{if .HasNext}}
                    <a href="{{.BaseURL}}?page={{.NextPage}}" hx-get="{{.BaseURL}}?page={{.NextPage}}" hx-target="#main-content" hx-push-url="true" class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0">
                        <span class="sr-only">Next</span>
                        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
                        </svg>
                    </a>
                    {{else}}
                    <span class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-200 cursor-not-allowed">
                        <span class="sr-only">Next</span>
                        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
                        </svg>
                    </span>
                    {{end}}
                </nav>
            </div>
        </div>
    </div>
`))

// Render generates the HTML for the pagination controls.
func (p Pagination) Render() template.HTML {
	var buf bytes.Buffer
	paginationTmpl.Execute(&buf, p)
	return template.HTML(buf.String())
}

// NewPagination is a helper for plugins to easily calculate pagination state
// It takes the current page, the limit (page size), and the slice of items fetched with limit+1
// It modifies the slice pointer to strip the extra item if present.
func NewPagination(baseURL string, page int, limit int, items *[]map[string]interface{}) Pagination {
    hasNext := len(*items) > limit
	if hasNext {
		*items = (*items)[:limit]
	}

	return Pagination{
		BaseURL:  baseURL,
		Page:     page,
		HasNext:  hasNext,
		HasPrev:  page > 1,
		NextPage: page + 1,
		PrevPage: page - 1,
	}
}
