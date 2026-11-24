#!/usr/bin/env python3
"""Render a helmscan --compare --json report as the release-notes CVE section.

Usage: helmscan_section.py <report.json> <prev-version> <new-version>
"""
import json
import sys

SEVERITIES = ["Critical", "High", "Medium", "Low"]


def table(cves, severity, heading):
    rows = sorted(
        (c for c in cves if c["severity"].lower() == severity.lower()),
        key=lambda c: c["id"],
    )
    if not rows:
        return []
    out = [f"{heading} {severity} ({len(rows)})", "", "| CVE ID | Affected images |", "| --- | --- |"]
    out += [f"| {c['id']} | {', '.join(sorted(c.get('affected_images') or []))} |" for c in rows]
    return out + [""]


def section(cves, title, empty):
    out = [f"### {title}", ""]
    body = [line for s in SEVERITIES for line in table(cves, s, "####")]
    return out + (body or [empty, ""])


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    path, prev, new = sys.argv[1:]
    with open(path) as f:
        report = json.load(f)

    counts = {c["severity"].lower(): c for c in report["summary"]["severity_counts"]}
    lines = [
        "## Helm chart CVE comparison",
        "",
        f"Trivy scan of every image rendered by the chart, comparing `kubecost/kubecost@{prev}` "
        f"with `kubecost/kubecost@{new}`. The severity counts below are total findings across all "
        "images, so a CVE affecting three images counts three times; the tables that follow list "
        "each CVE ID once.",
        "",
        "### Counts by severity",
        "",
        f"| Severity | {prev} | {new} | Change |",
        "| --- | --- | --- | --- |",
    ]
    for s in SEVERITIES:
        c = counts.get(s.lower(), {"previous_count": 0, "current_count": 0, "difference": 0})
        lines.append(f"| {s} | {c['previous_count']} | {c['current_count']} | {c['difference']:+d} |".replace("+0 |", "0 |"))
    lines.append("")
    lines += section(report.get("unchanged_cves") or [], "Unchanged CVEs", "No unchanged vulnerabilities.")
    lines += section(report.get("added_cves") or [], "Added CVEs", "No new vulnerabilities found.")
    lines += section(report.get("removed_cves") or [], "Removed CVEs", "No vulnerabilities removed.")
    print("\n".join(lines).rstrip())


if __name__ == "__main__":
    main()
