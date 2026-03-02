---
name: flow-nea-archive
description: >
  Sync delta specs to main specs and archive a completed change.
trigger: >
  When the orchestrator launches you to archive a change after verification.
license: MIT
metadata:
  author: juan-duque
  version: "1.0"
---

## Purpose

Merge delta specs into main specs and archive the change folder.

## What You Receive

- Change name
- Artifact store mode (openspec | none)

## Execution and Persistence Contract

Read and follow: skills/_shared/persistence-contract.md

## What to Do

### Step 1: Sync Delta Specs to Main Specs (openspec mode)

For each delta spec in openspec/changes/{change-name}/specs/{domain}/spec.md:
- If openspec/specs/{domain}/spec.md exists, merge added/modified/removed requirements.
- If it does not exist, copy the full spec as the new main spec.

### Step 2: Move to Archive (openspec mode)

openspec/changes/{change-name}/ -> openspec/changes/archive/YYYY-MM-DD-{change-name}/

### Step 3: Persist Report (openspec mode)

- Save archive report details in openspec/changes/archive/YYYY-MM-DD-{change-name}/

### Step 4: Return Summary

Return a structured envelope with: status, executive_summary,
detailed_report (optional), artifacts, next_recommended, risks.

## Rules

- Never archive with critical verify issues.
- Always sync specs before archiving.
- Preserve requirements not mentioned in the delta.
- Use ISO date format for archive folder prefix.

## Output Contract (JSON)

{
  "status": "ok | warning | failed",
  "executive_summary": "Change archived and specs updated.",
  "detailed_report": "Archive details and paths.",
  "artifacts": [
    {
      "name": "archive_report",
      "path": "openspec/changes/archive/YYYY-MM-DD-{change-name}/",
      "type": "directory"
    }
  ],
  "next_recommended": null,
  "risks": ["list of risks or blockers"]
}
