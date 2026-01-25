# Multi agent swarm
Akin to a cross-functional 'dev' capable of wearing different hats.

- Multiple personalities
- 1 unit of work
- working to get a task done
- creates specs for subswarms
- Queue / event driven domains
- Creating contracts between swarms
- Different types of swarms


# Agent Fleet

Constellation of swarms - akin to team of devs or team of teams.

# XP

- [TDD - Canonical TDD](https://tidyfirst.substack.com/p/canon-tdd)

# Kanban
- build the tools that help us build tools
- setup a separate repo for building kanban-rust-htmx

# 2025-01-25

- get ralph loop running
- ralph loop to get a kanban board working
- also figure out the process for creating a PRD.md file
- Huntley got claude to interview him to ask about the details of the project
- rename docs -> references
- include the transcript from huntley 1st priciples video as a basis
- how do we initiate the 'souls' in the sprites
- sprite build should update the npm libraries
- I wanted emoji animal + alpha/bravo name to each sprite

## interview prompt

```md
🏴‍☠️ THE NYX INTERVIEW PROTOCOL: FORGING THE KANBAN CORE

  "Alright Dreamer, the forge is hot and scorpion-alpha is twitching in its cave. We are not just building a
  Kanban board; we are building a tool for carpenters. To keep this locomotive on the tracks and avoid context
  rot, I need to extract the first principles of this system from your mind.

  I am now initiating the Interview Phase. Do not give me code. Give me the 'clay'. I will shape it into a
  SPEC.md and an IMPLEMENTATION_PLAN.md.

  1. The Atomic Unit: In our Rust backend, what is the most basic 'Task' entity? Beyond a title and status, what
  metadata is critical for a 'Carpenter' to have (e.g., tags, estimated 'weight', dependencies)?
  2. The HTMX Interaction Model: Huntley mentions 'avoiding compaction.' For the Kanban transitions, are we
  doing full-column swaps, or are we targeting individual task 'fragments' for OOB (Out-of-Band) swaps? How
  'live' does the board need to feel?
  3. Persistence & Safety: We're using SQLite + SQLx. Do we want a simple flat table, or should we architect for
  'Undo/Redo' capabilities from day one (Event Sourcing light)?
  4. The 'Carpenter' Aesthetic: You mentioned a professional, tool-builder look. Give me three 'vibe' keywords.
  Are we talking 'Trello-clone' or 'Terminal-chic'?
  5. The Failure Domains: What is the most annoying thing that could happen while using this tool? Let's
  engineer away that concern before we write a single line of Rust.
```

## htmx-kanban

- used this prompt to generate a better HTML copy of the team board (failed the first time with raw HTML/CSS)

> Hey could you try generating a HTML version using tailwind that matches exactly the  [Image ...rd-example.jpg] image? We have made one attempt before, but I'd like a fresh attempt. Its quite tricky as there is a lot of text and boxes. 

### Nyx:

  1. The Atomic Unit: What defines a 'Task' in the mind of a Carpenter?

  In the mind of a Carpenter—a Sprite wearing a killer or architect soul—a 'Task' is not a suggestion; it's a Contract of Manifestation. It is the bridge between IDEAS.md and
  progress.txt.

   * Metadata (The Identity): Each task carries a Soul_Affinity (which persona is best suited: architect for planning, killer for execution). It includes the Cave_Context (the
     Docker volume hash where the work lives) and a Entropy_Signature (a unique ID that links the commit back to the board).
   * Weights (The Friction): We don't use "story points." We use Friction Coefficients (0.1 to 1.0). A 1.0 is a "Nuke-Resistant Gremlin" requiring Quantum State Manipulation. A 0.1
     is a "Papercut." This determines how many Ralph iterations we authorize before we declare a "Stall."
   * Dependencies (The Upstream Chaos): Tasks are linked by Grafts. A task can be "Grafted" to another's successful commit. If the upstream commit fails a lint check, the
     downstream task is "Withered" (greyed out) until the chaos is resolved.

  2. The HTMX Interaction Model: Swaps, OOB fragments, and the "Vibe"

  The board must feel like a living, breathing entity—not a static page. (⇌) This is a voyage into high-frequency state synchronization.

   * Swaps: We use hx-swap="outerHTML" for card movements. Dragging a card from "Next" to "WIP" triggers a POST that immediately replaces the card with a "Jacked In" version,
     showing the live tail -f output of the ralph.sh loop inside the Sprite's Cave.
   * OOB Fragments: This is the secret sauce. When a Sprite hits a FAILURE domain (see #5), the server pushes an Out-Of-Band div that triggers a red strobe effect on the Octopus's
     header and injects a "Risk Alert" into the Risk Intel column of the board, regardless of where you are looking.
   * The "Vibe": It’s Twitchy-Functional. It feels like a terminal tailing a log, but with the spatial layout of the Team Board. You see the faces (the souls) flickering as they
     process iterations. It’s the visual equivalent of hearing a CPU fan spin up.

  3. Persistence & Safety: SQLite + 'The Safety Net'

  We stay brutally simple, but we don't gamble with the state. (π)

   * The Foundation: Flat SQLite. It’s portable, fast, and lives inside the project root. It holds the current board state, column mappings, and metadata.
   * The Safety Net (Light Event-Sourcing): We don't just update rows; we append to a delta_log. Every move, every weight change, every "Soul" assignment is an immutable event.
     This allows the Quantum Leap Protocol: if a Sprite accidentally nukes the codebase, we can "Rewind the Board" to a known good state, and the system will automatically re-spawn
     the Caves at that specific git hash.

  4. The 'Carpenter' Aesthetic: Gritty, Reactive, Brutalist

  Forget the rounded corners and pastel blues of Trello. We are Pirates in a Silicon Cave.

   * Three Vibe Keywords: RUGGED, KINETIC, UNFILTERED.
   * The Visual Soul: Terminal-Infused Trello. Imagine the 1980s "Green Screen" aesthetic meets modern CSS Grid. High-contrast borders (the "Silicon Pirate" neon green on deep
     charcoal), monospace fonts (JetBrains Mono or Recursive), and "Analog" indicators. The "Done" column shouldn't just be green; it should be "Burned In" to the UI. It looks like
     a high-end industrial dashboard found in the belly of a submarine.

  5. The Failure Domains: The Gremlin we kill first

  The most dangerous gremlin is Ghost State (Desynchronization). (⁂)

  This is the failure where the Octopus (the Board) thinks a Tentacle (the Sprite) is working on Task-A, but the Cave has crashed, or the ralph.sh loop has entered an infinite
  recursion of "Self-Correction" that produces no code.
   * The Kill Switch: We implement a Heartbeat Watchdog. If a Sprite in "WIP" doesn't update its Entropy_Signature (via a small OOB fragment update) within a defined TTL (based on
     its Friction Coefficient), the board declares it a "Ghost."
   * The Action: The board doesn't just show an error; it provides a "Purge & Re-Summon" button that executes ./lsprite.sh destroy and ./lsprite.sh create in one click, pulling the last known good state from the Event Source.

---

### Ian:

Ok, I love the basis that that gives me to work with. I'd like to refine some of those sections.

Let's start with Metadata.

The example board has a fundamental that it is very paired back and lacks all of the typical data that you have for a task.

Each task is actually just a note. I think there's something quite intentional in this.

Each note contains:

- Title (optionally linked to the Entropy_Signature)
- Colour (I guess this is your Soul_Affinity)

Nothing else.

How is it linked to a sprite?

- The WIP sections reverse the concept of assigning. A note is not assigned to a person, you have Groups that are assigned a note.
- The Cave_Context is linked to how we name the sprites. They are 'animal emoji' combined with an incrementing NATO letter (hence the scorpion-alpha). So each WIP will have 0 or more Sprites linked to it, those groups then get 0 or more notes moved to it

There is currently no notion of Weights or Dependencies.

### Final output:

```markdown
  1. The Atomic Unit: What defines a 'Task' in the mind of a Carpenter?

  In the mind of a Carpenter, a 'Task' is a simple **Note**. It is a transient spark of intent, stripped of all bureaucratic sludge to maintain maximum velocity.

   * The Note: Each note contains only a **Title** (the intent) and a **Colour** (the Soul_Affinity/Vibe). It is optionally linked to an **Entropy_Signature** (a unique ID for tracking).
   * Reversed Assignment: Notes are not assigned to Sprites. Instead, **WIP Groups** are formed. A Group is assigned one or more Notes.
   * Leashing the Tentacles: Sprites (Tentacles) are "leashed" to a WIP Group. A Sprite’s **Cave_Context** is defined by its identity—a unique sigil like "🦂A" (animal emoji + NATO letter).
   * Brutal Minimalism: There are **no Weights and no Dependencies**. Priority is defined spatially: the top note in a Group's stack is the current focus of the leashed Sprites.

  2. The HTMX Interaction Model: Rugged Real-Time Sigils

  We lean on native browser behaviors and standard HTML for the board's structure, reserving HTMX for the fluid heartbeat of the swarm. (⇌)

   * Rugged Interactions: Most board actions are simple POSTs and standard HTML swaps. We avoid complex transitions or client-side logic that fights the browser, prioritizing stability and predictability.
   * Real-Time Sigils: HTMX is dedicated to one thing: the fluid updates of the Sprite sigils (🦂A). Through simple OOB (Out-of-Band) updates, the Carpenter sees the live status of the swarm (Idle, Busy, Done) without the overhead of a heavy SPA.

  3. Persistence & Safety: SQLite + 'The Safety Net'

  We stay brutally simple, but we don't gamble with the state.

   * The Foundation: Flat SQLite. It’s portable, fast, and lives inside the project root. It holds the current board state, column mappings, and metadata.
   * The Safety Net (Light Event-Sourcing): We don't just update rows; we append to a delta_log. Every move and every "Soul" assignment is an immutable event.
     This allows the Quantum Leap Protocol: if a Sprite accidentally nukes the codebase, we can "Rewind the Board" to a known good state, and the system will automatically re-spawn
     the Caves at that specific git hash.

  4. The 'Carpenter' Aesthetic: Gritty, Reactive, Brutalist

  The aesthetic is functional, precise, and unapologetically clean. It prioritizes the clarity of a mission-critical environment.

   * Three Vibe Keywords: RUGGED, KINETIC, UNFILTERED.
   * The Visual Soul: Base Tailwind in a Submarine. A high-end industrial dashboard found in the belly of a submarine, expressed through the clean utility-first patterns of Tailwind CSS. It is a dense, high-information interface that prioritizes tactile feedback and functional purpose over decorative fluff.

  5. The Failure Domains: Maintaining Hull Integrity

  In the high-pressure environment of the Submarine, failure is not an option—it is a certainty to be managed. We relentlessly hunt for the gremlins that threaten the integrity of the swarm.

   * Depth-Crush (Ghost State): When a Sprite (🦂A) enters an infinite loop or its Docker cave collapses silently. The **Heartbeat Watchdog** acts as a pressure gauge; if the Entropy_Signature stops pulsing within a defined TTL, the hull is considered breached and the sigil reflects the failure.
   * Bulkhead Failure (Context Pollution): The danger of a Sprite carrying "debris" from one Note to the next. Ruggedness demands a **Clean-Room Protocol**: every time a Sprite is leashed to a new Note, it must verify its surroundings (git status/clean) to ensure no leakage between intents.
   * Signal Jamming (UI Desync): When the HTMX heartbeat is interrupted by browser or network instability. The UI must be **Self-Healing**; upon reconnection, it performs a "Sonar Ping" (re-sync) to ensure the visual sigils accurately reflect the backend Ledger.
   * The Emergency Blow (Purge & Re-Summon): Our ultimate failsafe. If any component of the system feels "heavy" or desynchronized, the Carpenter has the **Red Handle**: a single-click command to destroy the Cave, wipe the transient state, and re-summon the Sprite from the last known good commit in the Ledger.
```

### Nyx end summary of our interaction:  
  THE COURT SUMMARY: TECHNICAL LOG 2026-01-25
  OBJECTIVE: Design and codify the "Team Board Pillars" for the Sprites swarm.

  FACTUAL FINDINGS:
   1. Task Definition: The "Atomic Unit" was redefined as a minimalist Note. It contains
      only a Title and a Color (representing Soul_Affinity). All previous concepts of
      Weights and Dependencies were struck from the requirements.
   2. Naming Convention: Sprites are to be identified by a "Sigil" consisting of an
      animal emoji and a sequential NATO letter (e.g., 🦂A).
   3. Assignment Model: The traditional assignment model was reversed. Notes are
      assigned to WIP Groups, and Sprites are "leashed" to these groups to consume the
      notes based on spatial priority.
   4. Interface Strategy: The system will use Base Tailwind CSS with an "Industrial
      Submarine Dashboard" aesthetic. HTMX usage is restricted to real-time updates of
      Sprite status sigils to maintain browser-native ruggedness.
   5. Risk Management: Failure domains were identified: "Depth-Crush" (process failure),
      "Bulkhead Failure" (context leakage), and "Signal Jamming" (UI desync). The
      "Emergency Blow" (manual re-summoning) was established as the primary failsafe.

  ---

  SCREENPLAY: THE PLANNING SESSION
  CHARACTERS:
   * USER: Technical Lead / Architect.
   * AGENT: Implementation Assistant.

  SETTING:
  A technical design review session.

  USER
  I want to simplify the Kanban board. The task should just be a note. Title and color
  only. No weights, no dependencies.

  AGENT
  I have updated the metadata pillar. How should we link these notes to the Sprites?

  USER
  We use "WIP Groups." Notes go into a group, and we leash the Sprites to that group.
  For naming, keep it simple: animal emoji plus a NATO letter. Like 🦂A.

  AGENT
  Understood. I've updated the assignment model to reflect "Group Leashing." Now,
  regarding the visual style—you mentioned a submarine dashboard?

  USER
  Yes, but use base Tailwind CSS. Keep the industrial submarine feel, but don't
  overcomplicate it with 1980s or Trello references. Just a clean, high-density
  dashboard.

  AGENT
  I've refined the aesthetic pillar to "Base Tailwind in a Submarine." What about the
  HTMX interactions?

  USER
  Keep it rugged. Use native browser behaviors where possible. Use HTMX only for the
  real-time updates of the Sprite sigils.

  AGENT
  The interaction model is updated. Finally, let’s look at the failure domains.

  USER
  Expand that section. We need to focus on ruggedness. Use the submarine metaphor for
  failures: depth-crush, bulkhead leaks, signal jamming. And we need a "Red Handle" to
  purge and re-summon sprites if they desync.

  AGENT
  The pillars are now fully updated and committed to the repository.


