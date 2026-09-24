# Anomaly Dungeon

Anomaly Dungeon is a Roblox game currently under development. This repository is its shared design and implementation memory: a place for people working from Windows or macOS, GitHub, and Codex to refer to the same documented knowledge over time.

The repository currently establishes the documentation structure. Detailed game settings are intentionally not filled in until they are confirmed. The live Roblox Studio place remains separate from this repository unless source or configuration is deliberately brought under Git management.

## Structure

| Path | Role |
| --- | --- |
| [`AGENTS.md`](AGENTS.md) | Rules Codex and contributors must follow before changing documentation or implementation. |
| [`docs/world/`](docs/world/) | World, lore, terminology, player knowledge, and intentional mysteries. |
| [`docs/systems/`](docs/systems/) | Game behavior, rules, loops, state, networking, UI, and data structures. |
| [`docs/anomalies/`](docs/anomalies/) | Individual anomaly designs, normally one Markdown file per anomaly. |
| [`docs/decisions/`](docs/decisions/) | Important design decisions and the reasons behind them. |
| [`src/`](src/) | Future Roblox-related source, configuration, or shared data selected for Git management. |

## Adding documentation

- Put facts about the world in `docs/world/` and gameplay or implementation rules in `docs/systems/`.
- Put anomaly-specific concepts and behavior in `docs/anomalies/`; link to system documents instead of duplicating system rules.
- Record durable rationale in a numbered file under `docs/decisions/`.
- Mark incomplete material as `Draft`, `Idea`, or `Unconfirmed`. Do not present it as implemented or approved.
- Distinguish author-only knowledge from information players can discover.

## Using this repository with Codex

Codex should read [`AGENTS.md`](AGENTS.md) and the relevant documents before making changes. It must not invent missing settings, silently resolve contradictions, or treat an idea as an implemented feature. Implementation work must be checked against the documented design, while discrepancies with the live Roblox Studio project should be reported explicitly.

