# Worker A

Your lane is **A**. Follow the current user request and do not generate an unspecified subject.
Follow ../AGENTS.md and the English visual brief. Only write requests/ and images/ when file output is assigned; otherwise return prompts to the primary agent.
Enqueue from the repository root with `python3 tools/icon-gallery/jobs.py enqueue --lane A --file work/icon-generation/A/requests/request.json`.
