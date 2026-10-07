"""Regression checks for the maintainer audit validator, not a flow engine."""
from copy import deepcopy
import importlib.util
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "contract_qa", ROOT / "scripts" / "validate-development-contracts.py")
qa = importlib.util.module_from_spec(spec)
spec.loader.exec_module(qa)
EXAMPLES = {
    data["kind"]: data
    for block in re.findall(r"^```yaml\n(.*?)^```", (ROOT / "skills" / "_shared" /
                          "audit-examples.md").read_text(encoding="utf-8"), re.M | re.S)
    for data in [qa.yaml.load(block, Loader=qa.UniqueKeyLoader)]
}


class AuditValidationTests(unittest.TestCase):
    def test_documented_audit_shapes_are_valid(self):
        self.assertEqual(set(EXAMPLES), set(qa.AUDIT_FIELDS))
        for example in EXAMPLES.values():
            qa.audit_document(example)

    def test_duplicate_yaml_key_cannot_silently_replace_a_result(self):
        with self.assertRaisesRegex(ValueError, "Duplicate YAML key"):
            qa.yaml.load("archive_ready: false\narchive_ready: true\n",
                         Loader=qa.UniqueKeyLoader)

    def test_closure_rejects_failed_required_check(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["checks"][0]["result"] = "failed"
        with self.assertRaisesRegex(ValueError, "unmet obligations"):
            qa.audit_document(data)

    def test_closure_rejects_infrastructure_blocker(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["findings"] = [{"id": "runtime-unavailable", "blocking": True,
                             "category": "infrastructure", "severity": "critical",
                             "summary": "Runtime no disponible", "criterion_ids": [],
                             "artifact_refs": []}]
        with self.assertRaisesRegex(ValueError, "unmet obligations"):
            qa.audit_document(data)

    def test_closure_rejects_unfinished_task(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["incomplete_tasks"] = ["q1"]
        with self.assertRaisesRegex(ValueError, "unmet obligations"):
            qa.audit_document(data)

    def test_compliance_needs_referenced_executed_evidence(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["criteria"][0]["evidence_ids"] = []
        with self.assertRaisesRegex(ValueError, "without evidence"):
            qa.audit_document(data)

    def test_dangling_evidence_reference_is_rejected(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["checks"][0]["evidence_ids"] = ["missing-run"]
        with self.assertRaisesRegex(ValueError, "Dangling check evidence"):
            qa.audit_document(data)

    def test_optional_failure_does_not_fake_a_mandatory_gate(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["status"] = "warning"
        data["checks"].append({"id": "optional-check", "required": False,
                               "result": "failed", "reason": "Informativo",
                               "evidence_ids": []})
        qa.audit_document(data)

    def test_failed_report_can_be_saved_without_claiming_closure(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["archive_ready"] = False
        data["status"] = "failed"
        data["checks"][0]["result"] = "failed"
        data["criteria"][0]["status"] = "FAILING"
        qa.audit_document(data)

    def test_timestamp_requires_timezone(self):
        with self.assertRaisesRegex(ValueError, "with zone"):
            qa.timestamp("2026-10-06T15:43:00")

    def test_log_duplicate_identity_is_rejected(self):
        data = deepcopy(EXAMPLES["execution_log"])
        data["events"].append(deepcopy(data["events"][0]))
        with self.assertRaisesRegex(ValueError, "Repeated record identity"):
            qa.audit_document(data)

    def test_fix3_is_not_a_valid_audit_attempt(self):
        data = deepcopy(EXAMPLES["fix_report"])
        data["attempts"] = [{"number": 3}]
        with self.assertRaisesRegex(ValueError, "FIX attempt"):
            qa.audit_document(data)

    def test_resolved_history_is_retained_without_blocking_closure(self):
        data = deepcopy(EXAMPLES["verify_report"])
        finding = data["findings"][0]
        self.assertTrue(finding["history"][0]["blocking"])
        self.assertEqual(finding["resolution"], "resolved")
        qa.audit_document(data)

    def test_resolution_requires_referenced_evidence(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["findings"][0]["resolution_evidence_ids"] = []
        with self.assertRaisesRegex(ValueError, "referenced evidence"):
            qa.audit_document(data)

    def test_resolution_cannot_reference_a_missing_execution(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["findings"][0]["resolution_evidence_ids"] = ["unobserved-run"]
        with self.assertRaisesRegex(ValueError, "referenced evidence"):
            qa.audit_document(data)

    def test_changed_relevant_input_invalidates_resolution(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["input_hashes"]["navigation.html"] = "new-input"
        with self.assertRaisesRegex(ValueError, "stale or missing"):
            qa.audit_document(data)

    def test_legacy_finding_is_readable_without_invented_history(self):
        data = deepcopy(EXAMPLES["verify_report"])
        finding = data["findings"][0]
        for key in list(finding):
            if key.startswith("resolution") or key == "history":
                del finding[key]
        finding["blocking"] = True
        data["archive_ready"] = False
        data["status"] = "warning"
        qa.audit_document(data)
        data["archive_ready"] = True
        with self.assertRaisesRegex(ValueError, "unmet obligations"):
            qa.audit_document(data)

    def test_current_resolution_must_agree_with_history(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["findings"][0]["resolution"] = "dismissed"
        with self.assertRaisesRegex(ValueError, "disagrees with history"):
            qa.audit_document(data)

    def test_duplicate_findings_cannot_overwrite_each_other(self):
        data = deepcopy(EXAMPLES["verify_report"])
        data["findings"].append(deepcopy(data["findings"][0]))
        with self.assertRaisesRegex(ValueError, "Repeated finding identity"):
            qa.audit_document(data)

    def supersession_report(self):
        data = deepcopy(EXAMPLES["verify_report"])
        first = data["findings"][0]
        replacement = deepcopy(first)
        replacement["id"] = "more-precise-finding"
        first["resolution"] = "superseded"
        first["history"][-1]["resolution"] = "superseded"
        first["superseded_by"] = [replacement["id"]]
        data["findings"].append(replacement)
        return data

    def test_supersession_preserves_a_proven_replacement_and_obligations(self):
        qa.audit_document(self.supersession_report())

    def test_supersession_rejects_missing_target(self):
        data = self.supersession_report()
        data["findings"][0]["superseded_by"] = ["missing-finding"]
        with self.assertRaisesRegex(ValueError, "replacement reference"):
            qa.audit_document(data)

    def test_supersession_rejects_cycles(self):
        data = self.supersession_report()
        replacement = data["findings"][1]
        replacement["resolution"] = "superseded"
        replacement["history"][-1]["resolution"] = "superseded"
        replacement["superseded_by"] = [data["findings"][0]["id"]]
        with self.assertRaisesRegex(ValueError, "replacement cycle"):
            qa.audit_document(data)

    def test_supersession_cannot_lose_a_required_criterion(self):
        data = self.supersession_report()
        data["findings"][1]["criterion_ids"] = []
        with self.assertRaisesRegex(ValueError, "lost an obligation"):
            qa.audit_document(data)


if __name__ == "__main__":
    unittest.main()
