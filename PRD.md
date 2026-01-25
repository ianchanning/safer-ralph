# PRD: Rust + HTMX Kanban Board

**Goal:** Build a minimalist, high-performance Kanban board to manage the chaos. This is a tool for carpenters to build more tools.

## Core Tech Stack
- **Backend:** Rust (Axum or Actix-web).
- **Frontend:** HTML + HTMX + Tailwind CSS.
- **Persistence:** SQLite (via SQLx).

## Functional Requirements
- **Columns:** Backlog, In Progress, Done.
- **Tasks:** 
    - Create new tasks via a modal or inline form.
    - Drag-and-drop (or simple move buttons) between columns using HTMX.
    - Delete tasks.
    - Edit task descriptions.
- **Live Updates:** Ensure the UI stays snappy without full page reloads.

## Architectural Requirements (The "Carpenter" Way)
- **Modular Components:** Clear separation between Rust handlers and HTML fragments.
- **Fast Feedback Loop:** Optimize for rapid iteration.
- **Simplicity:** No over-engineering. The code should be the documentation.

## Phase 1: The Foundation
- [ ] Initialize Rust project with dependencies (Axum, SQLx, Askama/maud for templating).
- [ ] Setup basic SQLite schema.
- [ ] Serve a static index page with Tailwind and HTMX injected.
- [ ] Implement "List Tasks" endpoint and view.

## Phase 2: Interactivity
- [ ] Implement "Create Task" via HTMX.
- [ ] Implement "Move Task" (updating status in DB).
- [ ] Implement "Delete Task".

## Phase 3: Polish
- [ ] Tailwind styling for a clean, professional "Tool-Builder" aesthetic.
- [ ] Error handling and validation.