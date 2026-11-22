---
name: clock-in
description: Morning review of a night-shift run — show the report, then walk the night branch commit by commit (message, diff, tests, docs) so the user reviews every line, and route any problem to /postmortem. Use when the user says "clock in", "review last night", "what did the night shift do", or invokes /clock-in.
---

# Clock In

1. Read the newest `~/.claude/night-shift/<repo>-*.md` report for this repo and show it.
2. List the night branch commits oldest first: `git log --reverse --oneline <base>..night-shift/<date>`.
3. For each commit, one at a time: show the message, then the diff grouped as **tests → implementation → docs**. Wait for the user before moving on. Don't summarize the diff away — the user reviews every line.
4. When the user flags a problem: don't patch the code first. Run the postmortem skill, fix the doc/rule/test, then fix the code (as a new commit on the night branch).
5. End with a checklist the user does by hand:
   - [ ] Manually tried each change (note what you tried)
   - [ ] Triage `## Found overnight` and `## Needs input` in TODO.md
   - [ ] Pop the prep stash if one was made
   - [ ] Merge / open PR for the night branch (user's call)

Never push, merge, or open PRs yourself.
