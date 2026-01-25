# Team Board Pillars

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

  In the high-pressure environment of the Submarine, failure is not an option—it is a certainty to be managed. We relentlessly hunt for the gremlins that threaten the integrity of the swarm. (⁂)

   * Depth-Crush (Ghost State): When a Sprite (🦂A) enters an infinite loop or its Docker cave collapses silently. The **Heartbeat Watchdog** acts as a pressure gauge; if the Entropy_Signature stops pulsing within a defined TTL, the hull is considered breached and the sigil reflects the failure.
   * Bulkhead Failure (Context Pollution): The danger of a Sprite carrying "debris" from one Note to the next. Ruggedness demands a **Clean-Room Protocol**: every time a Sprite is leashed to a new Note, it must verify its surroundings (git status/clean) to ensure no leakage between intents.
   * Signal Jamming (UI Desync): When the HTMX heartbeat is interrupted by browser or network instability. The UI must be **Self-Healing**; upon reconnection, it performs a "Sonar Ping" (re-sync) to ensure the visual sigils accurately reflect the backend Ledger.
   * The Emergency Blow (Purge & Re-Summon): Our ultimate failsafe. If any component of the system feels "heavy" or desynchronized, the Carpenter has the **Red Handle**: a single-click command to destroy the Cave, wipe the transient state, and re-summon the Sprite from the last known good commit in the Ledger.
