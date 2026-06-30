# Error Handling Audit Report

## Summary

This report catalogs every error handling pattern across the Oasis Go codebase and recommends how each should be refactored to use the new `OasisError` type from `internal/errors`.

**Total error handling occurrences found: 78**

| Pattern | Count |
|---------|-------|
| `log.Fatal` / `log.Fatalf` | 30 |
| `log.Printf` (error logging) | 44 |
| `fmt.Errorf` | 2 |
| `http.Error` | 3 |
| `fmt.Fprintf(os.Stderr, ...)` | 8 |
| Bare `error` return | 3 |

---

## File: `main.go` (Host Server)

### 1. `log.Fatalf` — config load failure
- **Line 36**: `log.Fatalf("Failed to load configuration: %v", err)`
- **Recommendation**: Use `OasisError{Op: "loadConfig", Kind: KindConfig}`. The `main()` function can log the OasisError and exit, but the error itself should be structured.

### 2. `fmt.Errorf` — config file read
- **Line 111**: `return nil, fmt.Errorf("could not read config file: %w", err)`
- **Recommendation**: Replace with `OasisError{Op: "loadConfig.ReadFile", Kind: KindConfig, Err: err}`.

### 3. `fmt.Errorf` — YAML parse
- **Line 115**: `return nil, fmt.Errorf("could not parse yaml config: %w", err)`
- **Recommendation**: Replace with `OasisError{Op: "loadConfig.ParseYAML", Kind: KindConfig, Err: err}`.

### 4. `http.Error` — 404 no plugin match
- **Line 73**: `http.Error(w, "404 Not Found: No plugin registered for this path", http.StatusNotFound)`
- **Recommendation**: Create `OasisError{Op: "router", Kind: KindNotFound}` and use a helper to write it as an HTTP response.

### 5. `http.Error` — body read failure
- **Line 85**: `http.Error(w, "Failed to read request body", http.StatusInternalServerError)`
- **Recommendation**: Use `OasisError{Op: "router.ReadBody", Kind: KindInternal, Err: err}`.

### 6. `http.Error` — plugin RPC error
- **Line 95**: `http.Error(w, fmt.Sprintf("Plugin error: %s", err), http.StatusInternalServerError)`
- **Recommendation**: Use `OasisError{Op: "router.PluginCall", Kind: KindInternal, Err: err}`. Avoid leaking raw plugin errors to HTTP clients.

### 7. `log.Fatal` — ListenAndServe
- **Line 57**: `log.Fatal(http.ListenAndServe(":8080", masterHandler))`
- **Recommendation**: Wrap with `OasisError{Op: "main.ListenAndServe", Kind: KindInternal}`. Log the structured error, then exit.

### 8. `log.Printf` — RPC client creation failure
- **Line 132**: `log.Printf("Error creating RPC client for %s: %s", p.Name, err)`
- **Recommendation**: Use `OasisError{Op: "loadPlugins.Client", Kind: KindPlugin, Err: err}`. Consider returning an error from `loadPlugins` instead of just logging and continuing.

### 9. `log.Printf` — plugin dispense failure
- **Line 138**: `log.Printf("Error dispensing plugin %s: %s", p.Name, err)`
- **Recommendation**: Use `OasisError{Op: "loadPlugins.Dispense", Kind: KindPlugin, Err: err}`.

---

## File: `shared/plugin_server.go` (RPC Plugin Interface)

### 10. Bare error return — RPC server ServeHTTP
- **Line 42**: `return err` (from `s.Impl.ServeHTTP(req)`)
- **Recommendation**: Wrap with `OasisError{Op: "RPCServer.ServeHTTP", Kind: KindPlugin, Err: err}`.

### 11. Bare error return — RPC client ServeHTTP
- **Line 56**: `return HTTPResponse{}, err` (from `g.client.Call(...)`)
- **Recommendation**: Wrap with `OasisError{Op: "RPCClient.ServeHTTP", Kind: KindPlugin, Err: err}`. The existing comment on line 55 even says "You may want to wrap the error."

---

## File: `plugin/common.go` (Common Plugin)

### 12. `log.Fatalf` — database open failure
- **Line 41**: `log.Fatalf("Failed to open database: %v", err)`
- **Recommendation**: Use `OasisError{Op: "setupDatabase.Open", Kind: KindDatabase, Err: err}`. Refactor `setupDatabase` to return an error instead of calling `log.Fatalf`.

### 13. `log.Fatalf` — database ping failure
- **Line 51**: `log.Fatalf("Failed to ping database: %v", err)`
- **Recommendation**: Use `OasisError{Op: "setupDatabase.Ping", Kind: KindDatabase, Err: err}`.

### 14. Bare error return — NewRequest failure
- **Line 63**: `return shared.HTTPResponse{}, err`
- **Recommendation**: Wrap with `OasisError{Op: "ServeHTTP.NewRequest", Kind: KindInternal, Err: err}`.

### 15. Bare error return — ReadAll failure
- **Line 77**: `return shared.HTTPResponse{}, err`
- **Recommendation**: Wrap with `OasisError{Op: "ServeHTTP.ReadBody", Kind: KindInternal, Err: err}`.

### 16. Inline HTTP error — DB query failure (attendanceHandler)
- **Lines 99-103**: Manual JSON error response `{"error_message": "database connection"}`
- **Recommendation**: Use `OasisError{Op: "attendanceHandler.Query", Kind: KindDatabase, Err: err}` with an error-response helper. The current error message is misleading — it says "database connection" for all DB errors.

### 17. Inline HTTP error — row scan failure (attendanceHandler)
- **Lines 110-114**: Manual JSON error response `{"error_message": "database connection"}`
- **Recommendation**: Use `OasisError{Op: "attendanceHandler.Scan", Kind: KindDatabase, Err: err}`.

### 18. Inline HTTP error — rows iteration error (attendanceHandler)
- **Lines 120-124**: Manual JSON error response `{"error_message": "database connection"}`
- **Recommendation**: Use `OasisError{Op: "attendanceHandler.RowsErr", Kind: KindDatabase, Err: err}`.

---

## File: `command/generate/main.go` (DB Seed Script)

This file has the most error handling occurrences. It follows two patterns:
- **`log.Fatal`/`log.Fatalf`** for fatal setup errors (schema load, DB open, statement prepare)
- **`log.Printf`** for non-fatal insert errors (continues to next row)

### Fatal Errors (should use OasisError + fatal exit)

| # | Line | Code | Recommended Op | Recommended Kind |
|---|------|------|----------------|-----------------|
| 19 | 47 | `log.Fatal(err)` — DB open | `generate.OpenDB` | `KindDatabase` |
| 20 | 53 | `log.Fatalf("could not read sql file: %v", err)` | `generate.ReadSchema` | `KindConfig` |
| 21 | 59 | `log.Fatalf("could not execute schema: %v", err)` | `generate.ExecSchema` | `KindDatabase` |
| 22 | 170 | `log.Fatal(err)` — prepare Calendar | `seedCalendar.Prepare` | `KindDatabase` |
| 23 | 190 | `log.Fatal(err)` — prepare K12School | `seedK12Schools.Prepare` | `KindDatabase` |
| 24 | 209 | `log.Fatal(err)` — prepare K12Staff | `seedK12Staff.Prepare` | `KindDatabase` |
| 25 | 228 | `log.Fatal(err)` — prepare K12Student | `seedK12Students.Prepare` | `KindDatabase` |
| 26 | 254 | `log.Fatal(err)` — prepare CourseSection | `seedCourseSections.Prepare` | `KindDatabase` |
| 27 | 313 | `log.Fatal(err)` — prepare LEA | `seedLEA.Prepare` | `KindDatabase` |
| 28 | 337 | `log.Fatal(err)` — prepare SEA | `seedSEA.Prepare` | `KindDatabase` |
| 29 | 356 | `log.Fatal(err)` — prepare Facility | `seedFacility.Prepare` | `KindDatabase` |
| 30 | 375 | `log.Fatal(err)` — prepare EarlyLearningChild | `seedEarlyLearningChild.Prepare` | `KindDatabase` |
| 31 | 395 | `log.Fatal(err)` — prepare CTECourse | `seedCTECourse.Prepare` | `KindDatabase` |
| 32 | 415 | `log.Fatal(err)` — prepare Assessment | `seedAssessment.Prepare` | `KindDatabase` |
| 33 | 436 | `log.Fatal(err)` — prepare Program | `seedProgram.Prepare` | `KindDatabase` |
| 34 | 464 | `log.Fatal(err)` — prepare Goal | `seedGoal.Prepare` | `KindDatabase` |
| 35 | 479 | `log.Fatal(err)` — prepare LearnerActivity | `seedLearnerActivity.Prepare` | `KindDatabase` |
| 36 | 495 | `log.Fatal(err)` — prepare Rubric | `seedRubric.Prepare` | `KindDatabase` |
| 37 | 511 | `log.Fatal(err)` — prepare Scorer | `seedScorer.Prepare` | `KindDatabase` |
| 38 | 526 | `log.Fatal(err)` — prepare AuthenticationIdentityProvider | `seedAuthIdProvider.Prepare` | `KindDatabase` |
| 39 | 543 | `log.Fatal(err)` — prepare AuthorizationApplication | `seedAuthzApp.Prepare` | `KindDatabase` |
| 40 | 560 | `log.Fatal(err)` — prepare LearnerAction | `seedLearnerAction.Prepare` | `KindDatabase` |
| 41 | 577 | `log.Fatal(err)` — prepare AssessmentSubtest | `seedAssessmentSubtest.Prepare` | `KindDatabase` |
| 42 | 593 | `log.Fatal(err)` — prepare AssessmentItem | `seedAssessmentItem.Prepare` | `KindDatabase` |
| 43 | 610 | `log.Fatal(err)` — prepare AssessmentAsset | `seedAssessmentAsset.Prepare` | `KindDatabase` |
| 44 | 627 | `log.Fatal(err)` — prepare AssessmentForm | `seedAssessmentForm.Prepare` | `KindDatabase` |
| 45 | 648 | `log.Fatal(err)` — prepare EarlyChildhoodClassGroup | `seedECClassGroup.Prepare` | `KindDatabase` |
| 46 | 666 | `log.Fatal(err)` — prepare CTEProgram | `seedCTEProgram.Prepare` | `KindDatabase` |
| 47 | 688 | `log.Fatal(err)` — prepare CTECourseSection | `seedCTECourseSection.Prepare` | `KindDatabase` |
| 48 | 708 | `log.Fatal(err)` — prepare CalendarEvent | `seedCalendarEvent.Prepare` | `KindDatabase` |
| 49 | 724 | `log.Fatal(err)` — prepare CalendarCrisis | `seedCalendarCrisis.Prepare` | `KindDatabase` |
| 50 | 741 | `log.Fatal(err)` — prepare CourseSectionAttendance | `seedCSAttendance.Prepare` | `KindDatabase` |
| 51 | 758 | `log.Fatal(err)` — prepare CourseSectionEnrollment | `seedCSEnrollment.Prepare` | `KindDatabase` |
| 52 | 774 | `log.Fatal(err)` — prepare SEAFederalFunds | `seedSEAFederalFunds.Prepare` | `KindDatabase` |
| 53 | 790 | `log.Fatal(err)` — prepare SEAFinance | `seedSEAFinance.Prepare` | `KindDatabase` |
| 54 | 807 | `log.Fatal(err)` — prepare SEAJob | `seedSEAJob.Prepare` | `KindDatabase` |
| 55 | 824 | `log.Fatal(err)` — prepare FacilityAddress | `seedFacilityAddress.Prepare` | `KindDatabase` |
| 56 | 847 | `log.Fatal(err)` — prepare FacilityBudgetFinance | `seedFacBudgetFinance.Prepare` | `KindDatabase` |
| 57 | 863 | `log.Fatal(err)` — prepare FacilityCondition | `seedFacCondition.Prepare` | `KindDatabase` |
| 58 | 880 | `log.Fatal(err)` — prepare FacilityDesign | `seedFacDesign.Prepare` | `KindDatabase` |
| 59 | 897 | `log.Fatal(err)` — prepare FacilityManagement | `seedFacManagement.Prepare` | `KindDatabase` |
| 60 | 914 | `log.Fatal(err)` — prepare FacilityUtilization | `seedFacUtilization.Prepare` | `KindDatabase` |
| 61 | 933 | `log.Fatal(err)` — prepare ChildOutcomeSummary | `seedChildOutcome.Prepare` | `KindDatabase` |
| 62 | 950 | `log.Fatal(err)` — prepare EarlyLearningStaff | `seedELStaff.Prepare` | `KindDatabase` |
| 63 | 966 | `log.Fatal(err)` — prepare ParentGuardian | `seedParentGuardian.Prepare` | `KindDatabase` |
| 64 | 985 | `log.Fatal(err)` — prepare EarlyLearningDevelopmentObservation | `seedELDevObs.Prepare` | `KindDatabase` |
| 65 | 1002 | `log.Fatal(err)` — prepare EarlyChildhoodProgram | `seedECProgram.Prepare` | `KindDatabase` |
| 66 | 1019 | `log.Fatal(err)` — prepare CTECourseSectionAttendance | `seedCTECSAttendance.Prepare` | `KindDatabase` |
| 67 | 1037 | `log.Fatal(err)` — prepare CTEStudent | `seedCTEStudent.Prepare` | `KindDatabase` |
| 68 | 1066 | `log.Fatal(err)` — prepare AssessmentAdministration | `seedAssessAdmin.Prepare` | `KindDatabase` |
| 69 | 1082 | `log.Fatal(err)` — prepare AssessmentFormSection | `seedAssessFormSection.Prepare` | `KindDatabase` |
| 70 | 1099 | `log.Fatal(err)` — prepare AssessmentRegistration | `seedAssessReg.Prepare` | `KindDatabase` |
| 71 | 1116 | `log.Fatal(err)` — prepare AssessmentResult | `seedAssessResult.Prepare` | `KindDatabase` |
| 72 | 1133 | `log.Fatal(err)` — prepare AssessmentPerformanceLevel | `seedAssessPerfLevel.Prepare` | `KindDatabase` |
| 73 | 1152 | `log.Fatal(err)` — prepare AssessmentSession | `seedAssessSession.Prepare` | `KindDatabase` |
| 74 | 1168 | `log.Fatal(err)` — prepare AssessmentFormSubtestAssessmentItem | `seedAssessFormSubtestItem.Prepare` | `KindDatabase` |

### Non-Fatal Insert Errors (use OasisError for logging, continue)

All 44 `log.Printf("failed to insert ...")` calls follow the same pattern. Each should wrap the error:

```go
// Current:
log.Printf("failed to insert Calendar: %v", err)

// Recommended:
log.Printf("%v", &OasisError{Op: "seedCalendar.Exec", Kind: KindDatabase, Err: err})
```

These occur at the following lines (all `log.Printf`):
178, 197, 216, 235, 301, 320, 344, 363, 383, 402, 423, 443, 469, 486, 500, 516, 533, 549, 567, 584, 600, 616, 635, 656, 675, 696, 715, 730, 747, 764, 781, 797, 814, 830, 852, 869, 886, 903, 921, 940, 957, 974, 992, 1009, 1027, 1054, 1055, 1071, 1088, 1105, 1125, 1142, 1159, 1174

### Special case — QueryRow error
- **Line 1049**: `log.Printf("Could not find student %s to make a CTE student: %v", studentID, err)`
- **Recommendation**: Use `OasisError{Op: "seedCTEStudent.QueryRow", Kind: KindDatabase, Err: err}`.

---

## File: `command/chunk/split_csv.go` (CSV Utility)

### `fmt.Fprintf(os.Stderr, ...)` pattern (8 occurrences)

This CLI tool uses `fmt.Fprintf(os.Stderr, ...)` + `os.Exit(1)` consistently. These are:

| # | Line | Message | Recommended Op | Recommended Kind |
|---|------|---------|----------------|-----------------|
| 75 | 20-21 | "Error creating output directory" | `splitCSV.MkdirAll` | `KindConfig` |
| 76 | 27-28 | "Error opening input file" | `splitCSV.OpenFile` | `KindConfig` |
| 77 | 36-37 | "Error reading CSV" | `splitCSV.ReadCSV` | `KindConfig` |
| 78 | 40-41 | "Error: CSV is empty" | `splitCSV.ValidateCSV` | `KindValidation` |
| 79 | 54-55 | "Error: 'Domain' column not found" | `splitCSV.FindDomainCol` | `KindValidation` |
| 80 | 91-92 | "Error creating output file" | `writeChunk.CreateFile` | `KindInternal` |
| 81 | 101-102 | "Error writing header" | `writeChunk.WriteHeader` | `KindInternal` |
| 82 | 108-109 | "Error writing record" | `writeChunk.WriteRecord` | `KindInternal` |

**Recommendation**: These are fine for a CLI tool. Convert to `OasisError` for consistency, but keep the `os.Exit(1)` pattern since this is a standalone command-line utility, not a library.

---

## Recommended `Kind` Constants

Based on this audit, the `internal/errors` package should define at least:

| Kind | Usage |
|------|-------|
| `KindNotFound` | Route not found (404) |
| `KindInternal` | Unexpected internal errors |
| `KindConfig` | Configuration loading/parsing errors |
| `KindDatabase` | All DB-related errors (open, ping, query, scan, prepare, exec) |
| `KindPlugin` | Plugin loading, RPC client, dispense errors |
| `KindValidation` | Input validation errors (CSV, malformed data) |

---

## Key Observations

1. **`command/generate/main.go` dominates**: ~70 of the 78 occurrences are in this file. All the `db.Prepare` errors use the identical `log.Fatal(err)` pattern — a refactoring helper or wrapper function would reduce duplication significantly.

2. **Inconsistent error messages in `plugin/common.go`**: The `attendanceHandler` returns `{"error_message": "database connection"}` for three different error scenarios (query failure, scan failure, rows iteration error). These should be differentiated.

3. **Error leakage in `main.go:95`**: The router exposes raw plugin error messages to HTTP clients via `fmt.Sprintf("Plugin error: %s", err)`. This should be sanitized.

4. **`shared/plugin_server.go` has a TODO**: Line 55 says "You may want to wrap the error in something more specific" — this audit confirms that recommendation.

5. **No structured logging anywhere**: All logging uses `log.Printf`/`log.Fatal`. Consider adopting `slog` alongside `OasisError` for structured log output in a future pass.

6. **The seed script (`command/generate/main.go`) could benefit from a `mustPrepare` helper** to reduce the 30+ identical `log.Fatal(err)` blocks after `db.Prepare`.
