# SHADE — four-layer evaluation brief

Status: Draft. This is an evaluation brief for the existing Fox20 candidates, not a generation request or a new game specification.

## 1. Gameplay function — source facts

Source: `docs/systems/skill-build.md`, Exploration, rank 2, SHADE. The design draft describes straight-line teleportation while stealthed, with damage and stun along the path. Detection exceptions and the duration of invisibility remain unresolved. SHADE is a displayed draft name; no stable System ID has been established here. Do not convert these mechanics into props, numerical labels, enemy scenes, or new lore.

## 2. Visual metaphor — provisional treatment

Use the previous batch's visible idea: one anonymous humanoid rushing horizontally toward the right, pitched low, with a connected cyan-blue echo of the same pose behind it. This is a motion metaphor, not a claim that teleportation physically produces afterimages. A running pose alone may communicate ordinary movement instead; ask the reviewer what action they perceive before revealing the intended answer.

## 3. Visual design principles — extracted from the reference

From the existing Fox Illusion visual study, preserve horizontal directional flow, a compact leading silhouette, separation between the leading figure and its echo, narrow parallel trails, and contrast concentrated on the action. The existing blue/cyan palette is a study condition, not the game's approved palette.

Do not inherit reference-character identity, helmets, armor, clothes, weapons, vehicles, stage geometry, landscape, military HUD, logos, or typography. Avoid detailed anatomy or faces that compete with the action. Evaluate those features separately from the motion and echo. No source-reference image is embedded in the review artifact; the original batch's reference provenance remains in its brief.

## 4. Concrete depiction — review target, not submitted prompt

One cohesive side-view action image. A faceless anonymous humanoid is low and forward-pitched toward the right. One clearly separated translucent cyan echo repeats the leading pose behind it, with narrow straight light streaks trailing left. The backdrop is sparse and dark. The leading contour and echo remain distinct. No detailed costume, gear, landscape, border, text, or anatomical emphasis.

This description is a target for evaluating existing candidates. It has not been sent to SDXL. Retain the full square image, including existing bands and background: do not crop or recolor the candidates to make them pass.

## Review conditions and handoff

- Batch: `shade-20261014-fox20`; 20 existing images, frozen by byte-identical embedding and source SHA256 in `inputs.json`.
- Display: full square at 256 CSS px, plus 32/48/64 CSS px. These are trial conditions, not approved production sizes. Physical pixel size depends on browser zoom and device pixel ratio. The export records viewport size and device pixel ratio; use 100% browser zoom or record a different zoom in the review notes.
- Surrounding UI background: dark `#111827` and light `#f3f4f6`. Opaque image backgrounds remain intact. This does not test transparency or compositing of a cutout.
- Judge motion reading, pose/direction, same-pose echo, foreign visual content, and small-size readability independently. Record the surrounding background on each saved rating; assess both backgrounds separately if needed.
- Candidate selection, requests for revision, and skipping a candidate are review suggestions, not formal game-asset adoption.
- All human ratings start unanswered. No AI scores are prefilled. Human review files are explicitly downloaded; this page does not modify the gallery database.
- Stop after preparing one review set. No generation, paid API use, new agent run, publication, or Studio change.
