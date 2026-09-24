# AGENTS.md

## Repository purpose

This repository is the long-term shared memory for the design and implementation knowledge of the Roblox game **Anomaly Dungeon**. It primarily manages documentation; it is not assumed to be a mirror of the live Roblox Studio place.

## Core principles

- Preserve ambiguity when it is intentional. Missing information is not permission to invent plausible lore, rules, names, or implementation details.
- Confirm relevant documentation before changing a design or implementation.
- Do not silently alter an existing specification. Report contradictions and unresolved questions.
- Distinguish clearly between `Implemented`, `Designed`, `Draft`, `Idea`, and `Unconfirmed` information.
- Do not confuse **Player Anomaly** with **Anomaly Entity**.
- Do not confuse stable system IDs with names presented in the game.
- Keep world-building, game rules, anomaly-specific design, and decision rationale in their respective locations.

## Documentation map

- `docs/world/`: World, lore, terminology, and the boundary between author knowledge and player-accessible knowledge.
- `docs/systems/`: Game loops, rules, state transitions, data, networking, UI, and implementation-facing behavior.
- `docs/anomalies/`: One flexible document per individual anomaly, where practical.
- `docs/decisions/`: Significant decisions and their rationale. Supersede old decisions with new records instead of erasing history.
- `src/`: Future source code, shared configuration, or data that is appropriate for Git management.

## Before working

1. Read this file and the repository `README.md`.
2. Identify and read the documents relevant to the requested area.
3. Check the status labels and separate confirmed facts from drafts or ideas.
4. Check related decision records before proposing a conflicting change.
5. When implementation is involved, compare the intended change with the live Roblox Studio structure and document any assumptions.

## Change rules

- Respect existing assets and avoid unrelated rewrites.
- If documents conflict, report the conflict rather than resolving it silently.
- If a specification is unclear, record the uncertainty or ask for direction; do not fill the gap with invented material.
- When a design changes, update affected documents and add a decision record when the rationale will matter later.
- When implementation changes, verify consistency with the related world, system, anomaly, and decision documents.
- Use meaningful, focused commits.

## Anomaly documentation

Anomaly documents may include a system ID, game name, concept, behavior, visibility, triggers, interactions, prototype status, implementation notes, uncertainties, and related documents. These fields are optional and should reflect the anomaly rather than force every anomaly into one schema.

Names are not mandatory. Preserve established names such as **MiW**, **/dev/null**, **Mad Stomper**, and **Memory Swapper**. Treat a system ID such as `ANOMALY_MEMORY_SWAPPER` separately from its game name.

