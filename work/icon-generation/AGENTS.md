# Shared icon-study instructions

- Read the repository AGENTS.md, README.md, related source documents, and the current batch's visual brief before working.
- Write handoffs, variant labels, image prompts, negative prompts, and variant notes in English. The primary agent reports progress and summaries to the user in Japanese.
- Describe the requested visual image: pose, silhouette, afterimages, motion direction, colors, light, contrast, and framing. Do not substitute gameplay mechanics, ranks, damage, or stun rules for a visual brief.
- Treat these images as Draft production candidates. Do not establish game specifications, lore, character identity, costume, display names, or a standard production workflow from a generated image.
- Distinguish source facts from provisional visual treatment. Preserve unresolved design questions.
- Do not start generation without an explicit subject, count, and stopping condition.
- Verify that the selected OpenCode model is free when starting. Do not switch to a paid model. Record requested and observed models separately.
- Use lane A, B, or C. Only write your own requests/images when explicitly assigned file output; follow a prompt-only assignment when the primary agent handles saving and enqueueing. Do not overwrite another lane's work.
- Do not invoke Draw Things directly or launch concurrent GPU workers. Submit requests through tools/icon-gallery/jobs.py enqueue. Starting workers, external sharing, and server changes belong to the primary agent.
- Use an installed SDXL model filename and record source_docs actually read. Set target_id only when a stable existing System ID is provided; do not invent one.
- Store generation conditions and provisional notes in the image's JSON sidecar. Use actual English labels, never literal placeholders such as English.
- Do not treat timeouts or uncertain jobs as successful. Check Draw Things before retrying. Use amend only for queued jobs, preserving their Seed and job ID.
- Mobile reviews are stored in .runtime/gallery.sqlite3. Do not edit the database or another person's review directly.
- Never commit access keys, private gallery links, or .runtime files, or put them into generation requests.
- Operational instructions: ../../tools/icon-gallery/README.md.
