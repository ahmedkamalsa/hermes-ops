from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "improvement" / "registry.json"
RUN_LOG = ROOT / "hermes-run-log.jsonl"
STATUSES = {"candidate", "testing", "approved", "active", "rejected", "deprecated"}


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def load() -> dict:
    if not REGISTRY.exists():
        return {"version": 1, "updated_at": now(), "candidates": [], "events": []}
    return json.loads(REGISTRY.read_text(encoding="utf-8"))


def save(data: dict) -> None:
    REGISTRY.parent.mkdir(parents=True, exist_ok=True)
    data["updated_at"] = now()
    REGISTRY.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def event(data: dict, kind: str, message: str, candidate_id: str | None = None) -> None:
    data.setdefault("events", []).append(
        {"timestamp": now(), "kind": kind, "candidate_id": candidate_id, "message": message}
    )


def status() -> None:
    data = load()
    print(json.dumps({
        "registry": str(REGISTRY),
        "candidates": len(data.get("candidates", [])),
        "by_status": {
            s: sum(1 for c in data.get("candidates", []) if c.get("status") == s)
            for s in sorted(STATUSES)
        },
    }, ensure_ascii=False, indent=2))


def review() -> None:
    data = load()
    if not RUN_LOG.exists():
        save(data)
        status()
        return
    failures = []
    for line in RUN_LOG.read_text(encoding="utf-8", errors="ignore").splitlines()[-50:]:
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not row.get("ok"):
            failures.append(row)
    if len(failures) >= 3:
        candidate_id = "auto-failure-pattern-" + now().replace(":", "").replace(".", "")
        data.setdefault("candidates", []).append({
            "id": candidate_id,
            "status": "candidate",
            "created_at": now(),
            "title": "Repeated Hermes run failures",
            "evidence_count": len(failures),
            "activation_requires_human_approval": True,
            "proposal": "Inspect recent hermes-run-log.jsonl failures and propose a targeted skill/config/test improvement.",
        })
        event(data, "candidate_created", "Repeated failures created a candidate; not activated.", candidate_id)
    save(data)
    status()


def set_status(candidate_id: str, new_status: str) -> None:
    data = load()
    if new_status not in {"approved", "rejected"}:
        raise SystemExit("Only approve/reject are supported by CLI.")
    for candidate in data.get("candidates", []):
        if candidate.get("id") == candidate_id:
            candidate["status"] = new_status
            candidate["decided_at"] = now()
            event(data, new_status, f"Candidate {new_status} by human command.", candidate_id)
            save(data)
            status()
            return
    raise SystemExit(f"Candidate not found: {candidate_id}")


def main() -> None:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        status()
    elif cmd == "review":
        review()
    elif cmd in {"approve", "reject"} and len(sys.argv) == 3:
        set_status(sys.argv[2], "approved" if cmd == "approve" else "rejected")
    else:
        raise SystemExit("usage: improvement-manager.py status|review|approve <id>|reject <id>")


if __name__ == "__main__":
    main()
