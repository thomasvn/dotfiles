---
name: pr-another-pass
description: Take another pass at an open PR - look for simplifications and remaining bugs, rerun the tests, and update the PR body with the real results.
triggers: another pass, one more pass, take another pass at the PR, re-review the PR, simplify the PR, any remaining bugs, rerun the tests and update the PR body
---

# pr-another-pass

## When to use

The user names an open PR (URL or `owner/repo#N`) and asks for another pass: simplify it,
look for remaining bugs, rerun the tests, and refresh the PR body. With no PR named, use the
PR this session is working on.

## Rules

- Review the **PR head on GitHub**, not just local files. Git commands need the user's
  permission; asking for this pass on a PR you opened for them in this session counts as
  permission to fetch, commit and push to **its feature branch**. Otherwise, read remote code with
  `gh api` / `gh pr diff` and ask before committing.
- Never comment, review or reply on GitHub. Editing the PR **body** is part of this skill.
- Keep the git diff minimal. No drive-by refactors outside the PR's purpose.
- Skip nitpicks. Label edge cases by how likely they are, and keep them apart from
  default-path bugs.

## Steps

1. **Sync.** Get the head state and make sure the local worktree matches it:

   ```bash
   gh pr view N -R OWNER/REPO --json headRefName,headRefOid,baseRefName,body,statusCheckRollup
   git -C WORKTREE fetch origin && git -C WORKTREE status -sb   # must not be behind
   gh pr diff N -R OWNER/REPO
   ```

   No worktree yet: `git -C <clone> worktree add <path> origin/<head-branch>`.

2. **Read CI first.** For each failed check, read the log
   (`gh run view <id> --log-failed | grep -iE 'error|fail|assert'`) and decide whether the PR
   caused it. CI failures are bugs until you've shown otherwise.

3. **Simplify.** For every hunk, ask:
   - Can the hunk be deleted, or does it do something nobody asked for?
   - Is there a helper, variable or branch used only once? Inline it.
   - Is there a guard for a case that can't happen, or duplicated logic?
   - Could it be fewer lines while still reading well on the first pass?
   - Does every comment explain *why*, and is it needed?
   - Do the tests repeat setup that a parametrize or an existing helper already covers?

   Apply the simplifications that keep behavior the same. Then report them, or say plainly
   that you found none.

4. **Hunt bugs, and prove each one by running it.** Check:
   - the default path;
   - other callers of anything the PR changed (`grep` for its names);
   - config toggles and providers or modes the PR doesn't use itself;
   - parsers or readers of anything the PR's output feeds;
   - tests or health checks that assert on output the PR changes.

   Show a bug with a failing test or a scratch script (put it in `$KIROCREW_SCRATCH`) before
   calling it a bug. Fix real bugs minimally, and add a regression test to the existing test
   file for that source file.

5. **Run the tests.** Use the repo's own commands (`justfile`, `Makefile`, `AGENTS.md`, the CI
   workflow), then:
   - Run the tests closest to the change, and the full suite if it finishes in reasonable time.
     Otherwise, cite the CI run of the full suite at the head commit.
   - For a failure that might pre-date the PR, run the same tests on the base branch and
     compare the exact failure sets.
   - **Mutation check:** revert each fix on its own (`git show origin/BASE:<file> > <file>`),
     confirm that its test fails, then restore the fix.
   - Where possible, run the real path end to end against real input, such as a live PR or
     the built image, with outside writes stubbed or captured. Save the BEFORE and AFTER
     outputs.
   - Run the repo's linters and pre-commit hooks on the changed files.

6. **Commit and push** (if permitted) with a plain commit message, then wait for or check the
   new CI run.

7. **Refresh the PR body.** Re-read the live body (someone may have edited it) and the
   `PR notes` section and `PRs:` bullets of `~/.kiro/steering/AGENTS.md`. Then, in order:
   1. **Check it's still accurate** against the current head and this pass's results: fix
      claims about the code, commit SHAs, numbers and test output that changed, remove
      claims a new run disproved, and add any new test or reasoning a reviewer needs.
   2. **Simplify it further** following AGENTS.md: shorter visible text, plainer words,
      less of anything the diff already shows. Never cut collapsed test evidence.

   Save it with `gh pr edit N --body-file <file>`.

8. **Report in chat:** the simplifications made, bugs found (with proof) or "none found",
   test results, a link to the PR, and anything still unverified. Delete scratch files you
   no longer need.
