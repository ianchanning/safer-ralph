# Team Board Pillars

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
