from __future__ import annotations

import json
import os
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCOUT_JSON = ROOT / "free-model-scout.json"
OUT_JSON = ROOT / "model-benchmark.json"
OUT_MD = ROOT / "model-benchmark.md"


def load_env_key(name: str) -> str:
    if os.getenv(name):
        return os.environ[name]
    home = os.getenv("HERMES_HOME")
    if not home:
        return ""
    env_path = Path(home) / ".env"
    if not env_path.exists():
        return ""
    for line in env_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if line.startswith(name + "="):
            return line.split("=", 1)[1].strip().strip('"')
    return ""


def request_openrouter(model: str, key: str) -> dict:
    body = {
        "model": model,
        "messages": [{"role": "user", "content": "Reply with exactly: ok"}],
        "max_tokens": 16,
    }
    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    start = time.perf_counter()
    with urllib.request.urlopen(req, timeout=45) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    choices = data.get("choices") or []
    text = ""
    if choices:
        text = (choices[0].get("message") or {}).get("content") or ""
    return {"ok": bool(choices), "latency_ms": round((time.perf_counter() - start) * 1000), "text": text[:80]}


def main() -> None:
    if not SCOUT_JSON.exists():
        raise SystemExit("Run free-model-scout.py first.")
    key = load_env_key("OPENROUTER_API_KEY")
    models = []
    for item in json.loads(SCOUT_JSON.read_text(encoding="utf-8")).get("models", []):
        model_id = str(item.get("model_id") or "")
        if item.get("provider") != "openrouter" or not model_id.endswith(":free"):
            continue
        modality = str(item.get("modality") or item.get("architecture", "")).lower()
        if "audio" in modality or "image" in modality and not item.get("vision"):
            continue
        models.append(item)
    results = []
    for item in models[:5]:
        model = item["model_id"]
        if not key:
            results.append({"provider": "openrouter", "model_id": model, "ok": False, "error": "OPENROUTER_API_KEY missing"})
            continue
        try:
            result = request_openrouter(model, key)
            result.update({"provider": "openrouter", "model_id": model})
        except Exception as exc:
            result = {"provider": "openrouter", "model_id": model, "ok": False, "error": str(exc)[:180]}
        results.append(result)
        time.sleep(1)
    payload = {"generated_at": datetime.now(timezone.utc).isoformat(), "results": results}
    OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = ["# Model Benchmark", "", f"Generated: `{payload['generated_at']}`", "", "| Provider | Model | OK | Latency ms | Error |", "|---|---|---|---:|---|"]
    for row in results:
        lines.append(f"| {row.get('provider')} | `{row.get('model_id')}` | {row.get('ok')} | {row.get('latency_ms','')} | {row.get('error','')} |")
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"benchmarked": len(results), "json": str(OUT_JSON), "md": str(OUT_MD)}, indent=2))


if __name__ == "__main__":
    main()
