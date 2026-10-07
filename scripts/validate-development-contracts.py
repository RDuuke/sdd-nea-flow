"""Maintainer QA for development instructions; does not implement the flow.

Requires PyYAML for syntax checks only. Validates examples, response contracts,
relative documentation links and distribution checksums without project writes.
"""
from __future__ import annotations

import argparse
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import sys

try:
    import yaml
except ImportError:
    raise SystemExit("PyYAML is required for maintainer QA (not flow runtime).")

ROOT = Path(__file__).resolve().parents[1]
PHASES = ("init", "explore", "propose", "quick", "spec", "design", "tasks",
          "apply", "verify", "archive", "status", "continue")
RESPONSE_KEYS = {"status", "executive_summary", "artifacts", "next_recommended",
                 "risks", "skill_resolution"}
AUDIT_FIELDS = {
    "execution_log": {"events"}, "apply_progress": {"tasks"},
    "validation_plan": {"impact", "checks", "exceptions"},
    "verify_report": {"archive_ready", "input_hashes", "criteria", "checks",
                      "evidence", "findings", "incomplete_tasks"},
    "fix_report": {"attempts"},
    "archive_report": {"archive_path", "verification_ref", "domains"},
}


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject silent overwrites in YAML examples and frontmatter."""


def mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in result:
            raise ValueError(f"Duplicate YAML key: {key}")
        result[key] = loader.construct_object(value_node, deep=deep)
    return result


UniqueKeyLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, mapping)


def timestamp(value):
    if not isinstance(value, str) or datetime.fromisoformat(value).tzinfo is None:
        raise ValueError(f"Expected ISO datetime string with zone: {value!r}")


def unique_ids(items):
    ids = [item["id"] for item in items]
    if len(ids) != len(set(ids)):
        raise ValueError("Repeated record identity")
    return set(ids)


def finding_continuity(data):
    """Validate additive examples, not real-world execution or evidence currency."""
    findings = {item["id"]: item for item in data["findings"]}
    if len(findings) != len(data["findings"]):
        raise ValueError("Repeated finding identity")
    evidence = {item["id"] for item in data["evidence"]}
    resolutions = {"open", "resolved", "dismissed", "superseded"}
    graph = {}
    for identity, item in findings.items():
        resolution = item.get("resolution", "open")
        if resolution not in resolutions:
            raise ValueError("Invalid finding resolution")
        if not isinstance(item["blocking"], bool):
            raise ValueError("Finding blocking must be boolean")
        if "resolution" not in item:
            continue
        history = item.get("history", [])
        if not history:
            raise ValueError("Finding resolution needs observed history")
        for observation in history:
            timestamp(observation["at"])
            if (observation["resolution"] not in resolutions or
                    not isinstance(observation["blocking"], bool) or
                    not observation["summary"] or
                    not isinstance(observation["evidence_refs"], list) or
                    not isinstance(observation["input_hashes"], dict)):
                raise ValueError("Invalid finding history observation")
        if (history[-1]["resolution"] != resolution or
                history[-1]["blocking"] != item["blocking"]):
            raise ValueError("Finding current resolution disagrees with history")
        if resolution == "open":
            continue
        if item["blocking"]:
            raise ValueError("Terminal finding resolution cannot remain blocking")
        proof = set(item.get("resolution_evidence_ids", []))
        if not item.get("resolution_reason") or not proof or not proof <= evidence:
            raise ValueError("Finding resolution needs referenced evidence and reason")
        timestamp(item["resolution_at"])
        if resolution in ("resolved", "dismissed"):
            inputs = item.get("resolution_input_hashes", {})
            if not inputs or any(data["input_hashes"].get(k) != v for k, v in inputs.items()):
                raise ValueError("Finding resolution inputs are stale or missing")
        else:
            replacements = item.get("superseded_by", [])
            if (not replacements or len(replacements) != len(set(replacements)) or
                    identity in replacements or not set(replacements) <= findings.keys()):
                raise ValueError("Invalid finding replacement reference")
            inherited = {criterion for target in replacements
                         for criterion in findings[target]["criterion_ids"]}
            if not set(item["criterion_ids"]) <= inherited:
                raise ValueError("Finding replacements lost an obligation")
            graph[identity] = replacements
    visiting, visited = set(), set()

    def visit(identity):
        if identity in visiting:
            raise ValueError("Finding replacement cycle")
        if identity in visited:
            return
        visiting.add(identity)
        for target in graph.get(identity, []):
            visit(target)
        visiting.remove(identity)
        visited.add(identity)

    for identity in graph:
        visit(identity)


def audit_document(data):
    required = {"schema_version", "kind", "change", "updated_at", "status",
                "summary", "artifact_refs"} | AUDIT_FIELDS[data["kind"]]
    if not required <= data.keys():
        raise ValueError(f"Missing audit fields: {required - data.keys()}")
    if data["schema_version"] != "1.0" or data["status"] not in ("ok", "warning", "failed"):
        raise ValueError("Invalid audit version or status")
    timestamp(data["updated_at"])
    if data["kind"] == "execution_log":
        unique_ids(data["events"])
        for event in data["events"]:
            timestamp(event["started_at"])
            timestamp(event["finished_at"])
            if not isinstance(event["retried"], bool) or event["attempt"] < 1:
                raise ValueError("Invalid event retry metadata")
    elif data["kind"] == "verify_report":
        checks = unique_ids(data["checks"])
        evidence = unique_ids(data["evidence"])
        unique_ids(data["criteria"])
        for criterion in data["criteria"]:
            if not set(criterion["check_ids"]) <= checks or not set(criterion["evidence_ids"]) <= evidence:
                raise ValueError("Dangling criterion/check/evidence identity")
            if criterion["status"] == "COMPLIANT" and not criterion["evidence_ids"]:
                raise ValueError("Compliance without evidence")
        for check in data["checks"]:
            if check["result"] not in ("passed", "failed", "blocked", "not_run", "not_applicable"):
                raise ValueError("Invalid check result")
            if not set(check["evidence_ids"]) <= evidence:
                raise ValueError("Dangling check evidence")
        if not isinstance(data["archive_ready"], bool):
            raise ValueError("archive_ready must be boolean")
        if data["archive_ready"] and (data["incomplete_tasks"] or
                any(c["required"] and c["result"] != "passed" for c in data["checks"]) or
                any(c["status"] != "COMPLIANT" for c in data["criteria"]) or
                any(f["blocking"] for f in data["findings"])):
            raise ValueError("Example claims closure with unmet obligations")
        finding_continuity(data)
        for item in data["evidence"]:
            timestamp(item["started_at"])
            timestamp(item["finished_at"])
    elif data["kind"] == "fix_report":
        numbers = [a["number"] for a in data["attempts"]]
        if any(n not in (1, 2) for n in numbers) or len(numbers) != len(set(numbers)):
            raise ValueError("Invalid FIX attempt limit/identity")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skip-checksums", action="store_true")
    args = parser.parse_args()
    errors, counts = [], {"frontmatter": 0, "json": 0, "yaml": 0, "links": 0, "checksums": 0}
    skills = [ROOT / "skills" / f"flow-nea-{p}" / "SKILL.md" for p in PHASES]
    skills.append(ROOT / "skills" / "skill-creator" / "SKILL.md")
    docs = list((ROOT / "skills" / "_shared").glob("*.md")) + list((ROOT / "ai").glob("*.md"))
    files = skills + docs + [ROOT / "README.md", ROOT / "AGENTS.md"]
    files += [p for p in (ROOT / "examples").rglob("*.md")
              if "initiative" not in p.name]
    for path in files:
        try:
            text = path.read_text(encoding="utf-8-sig")
            if text.startswith("---\n"):
                header = yaml.load(text.split("---", 2)[1], Loader=UniqueKeyLoader)
                if path in skills and (header["name"] != path.parent.name or not header["description"]):
                    raise ValueError("Skill identity/description mismatch")
                counts["frontmatter"] += 1
            blocks = re.findall(r"^```(json|yaml)\s*\n(.*?)^```\s*$", text, re.M | re.S)
            responses = 0
            for kind, block in blocks:
                data = json.loads(block) if kind == "json" else yaml.load(block, Loader=UniqueKeyLoader)
                counts[kind] += 1
                if path in skills and kind == "json" and isinstance(data, dict) and "executive_summary" in data:
                    if not RESPONSE_KEYS <= data.keys():
                        raise ValueError(f"Missing phase response keys: {RESPONSE_KEYS - data.keys()}")
                    for artifact in data["artifacts"]:
                        if artifact["type"] not in ("markdown", "yaml", "directory"):
                            raise ValueError("Unsupported phase artifact type")
                    responses += 1
                if path.name == "audit-examples.md" and kind == "yaml":
                    audit_document(data)
            if path in skills and responses != 1:
                raise ValueError("Expected one standard phase JSON contract")
            # Documentation links only: target-project evidence refs are examples.
            for link in re.findall(r"\[[^\]\n]+\]\(([^)]+)\)", text):
                link = link.strip("<>").split("#", 1)[0]
                if not link or re.match(r"[a-z]+://", link) or "{" in link or link.startswith("/"):
                    continue
                target = (path.parent / link).resolve()
                if not target.exists():
                    raise ValueError(f"Missing documentation link: {link}")
                counts["links"] += 1
        except (ValueError, KeyError, TypeError, yaml.YAMLError) as exc:
            errors.append(f"{path.relative_to(ROOT)}: {exc}")
    if not args.skip_checksums:
        for line in (ROOT / "checksums.sha256").read_text().splitlines():
            if not line or line.startswith("#"):
                continue
            digest, name = line.split(maxsplit=1)
            if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
                errors.append(f"Checksum mismatch: {name}")
            counts["checksums"] += 1
    for error in errors:
        print(error, file=sys.stderr)
    print(json.dumps({"checked": counts, "errors": len(errors)}))
    return bool(errors)


if __name__ == "__main__":
    sys.exit(main())
