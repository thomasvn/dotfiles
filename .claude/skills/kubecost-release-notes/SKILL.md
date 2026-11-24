---
name: kubecost-release-notes
description: Draft Kubecost patch release notes from frontend, cost-model, and helm chart compare diffs, with an image list and a helmscan CVE comparison.
triggers: kubecost release notes, draft release notes, kubecost release, release notes for kubecost, helmscan, kubecost changelog
source: crystallize
---

# kubecost-release-notes

## When to use

The user wants release notes for a Kubecost version `NEW` (e.g. `3.3.1`) relative to `PREV`
(e.g. `3.3.0`). If either version is missing, infer `PREV` from
`gh release list -R kubecost/kubecost` (latest published) and ask only if `NEW` is unclear.

## Inputs

| Repo | Area in notes | Compare |
| --- | --- | --- |
| `kubecost/kubecost-frontend` | Frontend | `vPREV...vNEW` |
| `kubecost/kubecost-cost-model` | Cost Model | `vPREV...vNEW` |
| `kubecost/kubecost` | Helm Chart | `vPREV...vNEW` |

Frontend and cost-model are private; use `gh` (authenticated), not web fetch. If the user names
another repo (e.g. an operator), add it as its own section with the same procedure.

## Steps

1. Collect commits per repo:

   ```bash
   for r in kubecost-frontend kubecost-cost-model kubecost; do
     echo "== $r"
     gh api "repos/kubecost/$r/compare/vPREV...vNEW" --jq '.commits[].commit.message | split("\n")[0]'
   done
   ```

2. Read the PRs behind user-facing commits. Cherry-picks (`:cherries:`, `🍒`, `[cherry-pick]`,
   `(#orig) (#pick)`) carry little text; read the ORIGINAL PR (first number) for intent:

   ```bash
   gh pr view <N> -R kubecost/<repo> --json title,body,labels,files --jq '{title,body,labels:[.labels[].name],files:[.files[].path]}'
   ```

   Use `gh api repos/kubecost/<repo>/compare/vPREV...vNEW --jq '.files[].filename'` or
   `gh pr diff` when the PR body does not explain the user impact.

3. Drop noise: `Bump in-code version …`, rc bumps, CI/actions updates, CODEOWNERS, test-only and
   lint-only changes. Keep security fixes (Go version, `govulncheck`, dependency CVE bumps) as one
   concise bullet each. JIRA keys (`KCM-1234`) never appear in the notes.

4. Write each bullet for a customer:
   - One sentence, ideally under 20 words. Lead with the change; for fixes, name the symptom a user
     saw ("Fixed … could not be turned off"). Cut the mechanism, the why, and reviewer detail.
   - Anything a user must act on goes in a short `## Upgrade notes` section, not the bullet.
   - Wrap Helm values, API paths, Kubernetes kinds, and versions in backticks.
   - PR references: end the bullet with a link for PUBLIC repos only, citing the original PR (the
     first number of a cherry-pick) and every PR that shaped the change:
     `([#4825](https://github.com/kubecost/kubecost/pull/4825), [#4871](…/pull/4871))`.
     Check visibility with `gh repo view kubecost/<repo> --json visibility --jq .visibility`;
     never link or number PRs from PRIVATE repos (frontend and cost-model are private today).

   Before/after:

   | Too long | Concise |
   | --- | --- |
   | The network-costs DaemonSet no longer runs as a privileged container. It now defaults to `privileged: false`, … drops all capabilities except `NET_ADMIN`, which is all that is required to read conntrack flows. | network-costs no longer runs privileged; it needs only `NET_ADMIN` ([#4825](https://github.com/kubecost/kubecost/pull/4825)) |

5. Image list and image bumps from the rendered chart:

   ```bash
   helm repo update kubecost >/dev/null
   for v in PREV NEW; do
     helm template kc kubecost/kubecost --version "$v" | yq -N '.. | .image? | select(.)' | tr -d '"' | sort -u > "/tmp/kc-images-$v.txt"
   done
   diff /tmp/kc-images-PREV.txt /tmp/kc-images-NEW.txt
   ```

   Every changed tag becomes a Helm Chart bullet: ``Bump <name> image version `old` -> `new` ``,
   with the bump PR link(s) from `kubecost/kubecost`.
   The `NEW` file is the Image List.

6. Helm scan (needs `helmscan`, Trivy, helm, yq, jq). The README's Homebrew tap does not exist;
   if `helmscan` is not on PATH, build it from the kubecost fork:

   ```bash
   gh repo clone kubecost/helmscan /tmp/helmscan-src -- -q
   (cd /tmp/helmscan-src && go build -o /tmp/helmscan ./cmd/helmscan/main.go)
   ```

   Run from a scratch dir in the background; it writes `working-files/scans/<scan-name>/`
   relative to the CWD and takes about 2 minutes:

   ```bash
   mkdir -p /tmp/kc-helmscan && cd /tmp/kc-helmscan
   nohup /tmp/helmscan --compare --json --report --ignore-unfixed kubecost/kubecost@PREV kubecost/kubecost@NEW > scan.log 2>&1 &
   python3 <skill-dir>/scripts/helmscan_section.py "$(ls -t working-files/scans/*/*.json | head -1)" PREV NEW
   ```

   Paste the script output verbatim as the scan section. If helmscan cannot run, say so and leave a
   `<!-- TODO: helmscan -->` placeholder rather than inventing CVEs.

7. Assemble with the template below, omit any area section with no user-facing changes, save to
   `kubecost-NEW-release-notes.md`, and show the draft. Never create or edit the GitHub release.

## Template

```markdown
# Release Notes

## What's Changed

### Cost Model
- Fixed a bug where …

### Frontend
- …

### Helm Chart
- Use `discovery.k8s.io/v1` EndpointSlices on Kubernetes >= 1.21 ([#NNNN](https://github.com/kubecost/kubecost/pull/NNNN))
- Bump cluster-controller image version `v0.16.38` -> `v0.16.39` ([#NNNN](https://github.com/kubecost/kubecost/pull/NNNN))

## Upgrade notes
- <only when users must act; omit otherwise>

## Image List
A list of all images which the Helm chart installs by default:

- icr.io/kubecost/frontend:NEW
- icr.io/kubecost/cost-model:NEW
- …

## Helm chart CVE comparison
<output of scripts/helmscan_section.py>
```

## Gotchas

- A stale local helm index hides the new chart version; always `helm repo update kubecost` first.
- The rendered chart includes a curl image (`basicHealth`); list it, since it installs by default.
- helmscan severity counts are total findings across images; the tables dedupe by CVE ID. The
  script's intro sentence states this — keep it.
- PREV's counts come from today's Trivy DB, so they will not match the CVE table published in
  PREV's own release notes. That is expected; do not "correct" them.
- Read the Helm values diff (`compare … --jq '.files[] | select(.filename=="kubecost/values.yaml") | .patch'`):
  a renamed or removed value is a breaking change and goes in an `## Upgrade notes` section.
- `--ignore-unfixed` matches the existing published reports; drop it only if the user asks for all
  CVEs, and say so in the section intro.
