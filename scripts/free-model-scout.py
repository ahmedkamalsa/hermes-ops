from __future__ import annotations

import json
import os
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "free-model-scout.json"
OUT_MD = ROOT / "free-model-scout.md"


def price_zero(value: object) -> bool:
    try:
        return float(value or 0) == 0.0
    except (TypeError, ValueError):
        return False


def fetch_json(url: str, headers: dict[str, str] | None = None) -> dict:
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def openrouter_models() -> list[dict]:
    data = fetch_json("https://openrouter.ai/api/v1/models")
    rows = []
    for item in data.get("data", []):
        pricing = item.get("pricing") or {}
        if not (price_zero(pricing.get("prompt")) and price_zero(pricing.get("completion"))):
            continue
        arch = item.get("architecture") or {}
        supported = item.get("supported_parameters") or []
        rows.append(
            {
                "provider": "openrouter",
                "model_id": item.get("id"),
                "context_length": item.get("context_length"),
                "tool_calling": "tools" in supported or "tool_choice" in supported,
                "reasoning": "reasoning" in supported,
                "vision": bool(arch.get("modality") and "image" in str(arch.get("modality")).lower()),
                "price": pricing,
                "availability": "catalog",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        )
    return rows


def lmstudio_models() -> list[dict]:
    base = os.getenv("LMSTUDIO_BASE_URL", "http://127.0.0.1:1234/v1").rstrip("/")
    try:
        data = fetch_json(f"{base}/models")
    except Exception as exc:
        return [
            {
                "provider": "lmstudio",
                "availability": "unreachable",
                "error": str(exc)[:160],
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        ]
    rows = []
    for item in data.get("data", []):
        rows.append(
            {
                "provider": "lmstudio",
                "model_id": item.get("id"),
                "context_length": None,
                "tool_calling": None,
                "reasoning": None,
                "vision": None,
                "price": {"prompt": "0", "completion": "0"},
                "availability": "local",
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        )
    return rows


def write_report(rows: list[dict]) -> None:
    payload = {"generated_at": datetime.now(timezone.utc).isoformat(), "models": rows}
    OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = ["# Free Model Scout", "", f"Generated: `{payload['generated_at']}`", "", "| Provider | Model | Context | Tools | Reasoning | Vision | Availability |", "|---|---|---:|---|---|---|---|"]
    for row in rows:
        lines.append(
            f"| {row.get('provider','')} | `{row.get('model_id','')}` | {row.get('context_length') or ''} | {row.get('tool_calling')} | {row.get('reasoning')} | {row.get('vision')} | {row.get('availability','')} |"
        )
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    rows = []
    rows.extend(openrouter_models())
    rows.extend(lmstudio_models())
    rows.sort(key=lambda r: (r.get("provider", ""), str(r.get("model_id", ""))))
    write_report(rows)
    print(json.dumps({"models": len(rows), "json": str(OUT_JSON), "md": str(OUT_MD)}, indent=2))


if __name__ == "__main__":
    main()
