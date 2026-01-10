# Product Requirement Document: OASIS

## 1. Executive Summary
**OASIS** (Obviously Awesome Student Information System) is an open-source, extensible Student Information System designed to provide schools with essential administrative features while allowing infinite customization through a plugin architecture. The system decouples core routing and lifecycle management from specific business logic (e.g., grades, attendance), which are handled by independent plugins.

## 2. Product Vision
To create the "Linux of Student Information Systems"—a minimal, stable kernel that allows schools to extend functionality via plugins without being locked into a proprietary ecosystem.

## 3. Technical Architecture

### 3.1 Tech Stack
* **Core Language:** Go (v1.23.4)
* **Plugin System:** `hashicorp/go-plugin` (v1.6.2) via RPC over local network/process
* **Database:** SQLite (`modernc.org/sqlite`) - Currently embedded, utilizing WAL mode and connection pooling
* **Configuration:** YAML (`plugins.yaml`)
* **Testing:** k6 for load testing
* **Standardization:** Aligned with CEDS (Common Education Data Standards) domains (e.g., K12, Early Learning, CTE) via CSV chunking and seeding tools.

### 3.2 System Components
The architecture follows a **Modular Monolith / Process-Based Microservices** pattern:

1.  **The Host (Kernel) (`main.go`)**
    * **Responsibility:** Lifecycle management (boot/shutdown), configuration loading, and request routing.
    * **Routing Mechanism:** A reverse proxy that matches URL prefixes (e.g., `/api/common`) to registered plugins and forwards HTTP requests via RPC.
    * **Concurrency:** Monitors OS signals (`SIGINT`, `SIGTERM`) to ensure graceful shutdown of all child plugin processes.

2.  **The Shared Protocol (`shared/`)**
    * Defines the contract between Host and Plugins.
    * **Interface:** `HTTPPlugin` containing the `ServeHTTP` method.
    * **Transport:** Custom `HTTPRequest` and `HTTPResponse` structs serialized over `net/rpc`.
    * **Handshake:** Uses a Magic Cookie (`HTTP_PLUGIN`) to ensure plugin compatibility.

3.  **Plugins (e.g., `plugin/common.go`)**
    * Standalone binaries executed by the Host.
    * Maintain their own internal routers (`http.ServeMux`).
    * Manage independent database connections (currently shared SQLite file access).

4.  **Data Layer (`command/generate`)**
    * A complex relational schema populated with realistic fake data using `faker/v3`.
    * **Entities:** Covers domains such as K12 Students, Staff, CTE (Career & Technical Education), Assessments, and Facilities.

## 4. Directory Structure

    .
    ├── catdevman/oasis/
    │   ├── main.go                # Host Application entry point
    │   ├── plugins.yaml           # Plugin registration config
    │   ├── go.mod                 # Core dependencies
    │   ├── Makefile               # Build scripts for host and plugins
    │   ├── script.js              # k6 load testing script
    │   │
    │   ├── shared/                # Shared Interface Definitions
    │   │   └── plugin_server.go   # RPC implementation & HTTP adapters
    │   │
    │   ├── plugin/                # Plugin Source Code
    │   │   └── common.go          # Example "Common" plugin (Grades/Attendance)
    │   │
    │   └── command/               # Utility CLI tools
    │       ├── generate/          # Data Seeding Tool
    │       │   ├── main.go        # Seeder logic
    │       │   └── full.sql       # Database Schema
    │       └── chunk/             # CSV Processing
    │           └── split_csv.go   # Utility to split CEDS domain CSVs

## 5. Functional Requirements

### 5.1 Core System
* **Dynamic Plugin Loading:** The system must read `plugins.yaml`, execute the binaries defined in `path`, and establish an RPC connection.
* **Prefix Routing:** Traffic must be routed based on the `prefix` defined in the configuration. The host uses a "best match" (longest prefix) algorithm.
* **Graceful Shutdown:** On receiving `SIGINT` or `SIGTERM`, the host must iterate through all active clients and kill them to prevent zombie processes.

### 5.2 Data Management
* **Schema:** The system relies on a extensive SQL schema (`full.sql`) capable of supporting complex educational data scenarios.
* **Seeding:** The `command/generate` tool must be able to wipe and repopulate the database with consistent foreign key relationships (e.g., Students linked to Course Sections).

### 5.3 Extensibility
* **Independent Operation:** Plugins must be able to serve standard HTTP responses (JSON) and operate independently of the host's internal logic, sharing only the Interface definition.
* **Database Access:** Plugins currently establish their own connections to the SQLite file, utilizing connection pooling (Max Open Conns: 25) and WAL mode.

## 6. Known Constraints & Risks
* **Database Locking:** Multiple plugins accessing the same SQLite file (`oasis.db`) risks `SQLITE_BUSY` errors under high concurrency, though WAL mode is enabled to mitigate this.
* **Commercial Use:** The source is viewable but not open for commercial use without contacting the author. No license is currently provided.
* **Security:** Authentication is currently modeled via data seeding (Identity Providers) but is not enforced at the Host gateway level.

## 7. Roadmap / Future Work
* **Conflict Resolution:** Implement logic to detect and handle plugins registering identical route prefixes or conflicting commands.
* **Plugin Load Order:** Introduce a dependency resolution mechanism or explicit load order in the configuration.
* **Frontend:** Develop a unified web interface to aggregate UI fragments from various plugins.
* **Containerization:** Create a `Dockerfile` for deployment (Note: Ensure `Dockerfile` does not use `#` for comments, as per strict user constraints).
