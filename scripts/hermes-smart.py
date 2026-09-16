from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCOUT = ROOT / "free-model-scout.json"
BENCH = ROOT / "model-benchmark.json"
REGISTRY = ROOT / "model-health-registry.json"

STATES = {
    "HEALTHY",
    "DEGRADED",
    "RATE_LIMITED",
    "AUTH_REQUIRED",
    "UNAVAILABLE",
    "PAID",
    "UNKNOWN",
}

TASK_CLASSES = {
    "LOCAL_SIMPLE": ["lmstudio", "openrouter", "gemini", "huggingface"],
    "CODING": ["openrouter", "gemini", "huggingface", "lmstudio"],
    "RESEARCH": ["openrouter", "gemini", "huggingface", "lmstudio"],
    "REASONING": ["openrouter", "gemini", "huggingface", "lmstudio"],
    "AUXILIARY": ["lmstudio", "openrouter", "gemini", "huggingface"],
    "REAL_ESTATE": ["openrouter", "gemini", "huggingface", "lmstudio"],
    "CODEX_HEAVY": ["openai-codex"],
}

PRESERVE_FIRST_CANDIDATES = [
    {
        "provider": "gemini",
        "model_id": "gemini-2.5-flash",
        "credential_env": ("GOOGLE_API_KEY", "GEMINI_API_KEY"),
        "state": "AUTH_REQUIRED",
        "current_price": {"prompt": "0", "completion": "0", "basis": "official free tier/rate limits"},
        "context_length": 1048576,
        "capabilities": {"tool_calling": True, "reasoning": True, "vision": True},
        "availability": "candidate",
    },
    {
        "provider": "huggingface",
        "model_id": "inclusionAI/Ling-3.0-flash-VL",
        "credential_env": ("HF_TOKEN",),
        "state": "AUTH_REQUIRED",
        "current_price": {"prompt": "0", "completion": "0", "basis": "provider model table"},
        "context_length": 262144,
        "capabilities": {"tool_calling": True, "reasoning": True, "vision": True},
        "availability": "candidate",
    },
]

EMBEDDING_MARKERS = ("embedding", "embed", "text-embedding")


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_json(path: Path, default):
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8-sig"))


def save_json(path: Path, payload) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def key_for(provider: str, model_id: str) -> str:
    return f"{provider}/{model_id}"


def zero_price(price: dict | None) -> bool:
    if not isinstance(price, dict):
        return False
    try:
        return float(price.get("prompt") or 0) == 0 and float(price.get("completion") or 0) == 0
    except (TypeError, ValueError):
        return False


def is_embedding_model(model_id: str) -> bool:
    mid = (model_id or "").lower()
    return any(marker in mid for marker in EMBEDDING_MARKERS)


def is_agentic_task(task_class: str) -> bool:
    return task_class in {"CODING", "REAL_ESTATE"}


def supports_agentic_tools(model: dict, task_class: str) -> bool:
    if not is_agentic_task(task_class):
        return True
    if model.get("provider") == "lmstudio":
        return True
    return model.get("capabilities", {}).get("tool_calling") is True


def current_registry() -> dict:
    return load_json(REGISTRY, {"updated_at": now(), "models": {}, "events": []})


def mark_from_catalog(reg: dict) -> dict:
    catalog = load_json(SCOUT, {"models": []})
    refresh_time = catalog.get("generated_at") or now()
    for item in catalog.get("models", []):
        provider = item.get("provider") or "unknown"
        model_id = item.get("model_id") or ""
        if not model_id:
            continue
        k = key_for(provider, model_id)
        old = reg["models"].get(k, {})
        free = zero_price(item.get("price"))
        state = old.get("state", "UNKNOWN")
        if provider == "lmstudio" and item.get("availability") == "local" and free:
            state = "HEALTHY"
        elif not free:
            state = "PAID"
        elif state in {"PAID", "UNAVAILABLE", "AUTH_REQUIRED", "RATE_LIMITED"}:
            state = "UNKNOWN"
        reg["models"][k] = {
            **old,
            "provider": provider,
            "model_id": model_id,
            "state": state,
            "active": old.get("active", True) if state != "PAID" else False,
            "last_catalog_refresh": refresh_time,
            "last_health_check": refresh_time if provider == "lmstudio" and item.get("availability") == "local" else old.get("last_health_check"),
            "last_success": refresh_time if provider == "lmstudio" and item.get("availability") == "local" else old.get("last_success"),
            "current_price": item.get("price"),
            "context_length": item.get("context_length"),
            "capabilities": {
                "tool_calling": item.get("tool_calling"),
                "reasoning": item.get("reasoning"),
                "vision": item.get("vision"),
            },
            "availability": item.get("availability"),
            "consecutive_failures": int(old.get("consecutive_failures") or 0),
            "history": old.get("history", []),
        }
    reg["updated_at"] = now()
    return reg


def mark_preserve_first_candidates(reg: dict) -> dict:
    refresh_time = now()
    for item in PRESERVE_FIRST_CANDIDATES:
        k = key_for(item["provider"], item["model_id"])
        old = reg["models"].get(k, {})
        if old.get("state") == "HEALTHY":
            state = "HEALTHY"
            active = True
        else:
            state = old.get("state") if old.get("state") in STATES else item["state"]
            active = old.get("active", False) if state != "AUTH_REQUIRED" else False
        reg["models"][k] = {
            **old,
            "provider": item["provider"],
            "model_id": item["model_id"],
            "state": state,
            "active": active,
            "last_catalog_refresh": refresh_time,
            "last_health_check": old.get("last_health_check"),
            "last_success": old.get("last_success"),
            "current_price": item["current_price"],
            "context_length": item["context_length"],
            "capabilities": item["capabilities"],
            "availability": item["availability"],
            "credential_env": list(item["credential_env"]),
            "consecutive_failures": int(old.get("consecutive_failures") or 0),
            "history": old.get("history", []),
        }
    reg["updated_at"] = refresh_time
    return reg


def mark_from_benchmark(reg: dict) -> dict:
    bench = load_json(BENCH, {"results": []})
    check_time = bench.get("generated_at") or now()
    for result in bench.get("results", []):
        k = key_for(result.get("provider") or "unknown", result.get("model_id") or "")
        if k not in reg["models"]:
            continue
        row = reg["models"][k]
        ok = bool(result.get("ok"))
        error = str(result.get("error") or "")
        if ok:
            row["state"] = "HEALTHY"
            row["active"] = True
            row["last_success"] = check_time
            row["consecutive_failures"] = 0
        elif "429" in error:
            row["state"] = "RATE_LIMITED"
            row["active"] = False
            row["consecutive_failures"] = int(row.get("consecutive_failures") or 0) + 1
        elif "401" in error or "403" in error:
            row["state"] = "AUTH_REQUIRED"
            row["active"] = False
            row["consecutive_failures"] = int(row.get("consecutive_failures") or 0) + 1
        elif "402" in error or "Payment Required" in error:
            row["state"] = "PAID"
            row["active"] = False
            row["consecutive_failures"] = int(row.get("consecutive_failures") or 0) + 1
        else:
            row["state"] = "UNAVAILABLE"
            row["active"] = False
            row["consecutive_failures"] = int(row.get("consecutive_failures") or 0) + 1
        row["last_health_check"] = check_time
        row.setdefault("history", []).append(
            {
                "timestamp": check_time,
                "ok": ok,
                "latency_ms": result.get("latency_ms"),
                "state": row["state"],
                "error_class": error[:80] if error else "",
            }
        )
    reg["updated_at"] = now()
    return reg


def select(task_class: str) -> dict:
    reg = current_registry()
    task_class = task_class.upper()
    providers = TASK_CLASSES.get(task_class, TASK_CLASSES["LOCAL_SIMPLE"])
    if task_class == "CODEX_HEAVY":
        return {
            "task_class": task_class,
            "runtime_failover": [
                "explicit Codex escalation only",
                "single attempt",
                "return to local/free route or request approval on failure",
            ],
            "selected": {
                "provider": "openai-codex",
                "model_id": "gpt-5.5",
                "state": "HEALTHY",
                "active": True,
                "current_price": {"prompt": "subscription", "completion": "subscription"},
                "capabilities": {"tool_calling": True, "reasoning": True, "vision": None},
                "availability": "explicit-escalation-only",
            },
            "alternatives": [],
            "paid_requires_approval": True,
            "codex_escalation_only": True,
        }
    healthy = []
    for m in reg.get("models", {}).values():
        if not (
            m.get("active", True)
            and m.get("state") == "HEALTHY"
            and zero_price(m.get("current_price"))
            and m.get("provider") in providers
        ):
            continue
        if is_embedding_model(m.get("model_id") or ""):
            continue
        if not supports_agentic_tools(m, task_class):
            continue
        healthy.append(m)
    healthy.sort(
        key=lambda m: (
            providers.index(m.get("provider")) if m.get("provider") in providers else 99,
            0 if task_class == "LOCAL_SIMPLE" and m.get("model_id") == "qwen3.5-4b" else 1,
            -(m.get("context_length") or 0),
            m.get("model_id") or "",
        )
    )
    return {
        "task_class": task_class,
        "runtime_failover": [
            "local healthy model",
            "best currently verified free model for task class",
            "next verified free model",
            "explicit Codex escalation only for heavy coding/reasoning",
            "stop and request approval before paid/unknown model",
        ],
        "selected": healthy[0] if healthy else None,
        "alternatives": healthy[1:5],
        "paid_requires_approval": True,
    }


def refresh_registry() -> None:
    reg = mark_from_catalog(current_registry())
    reg = mark_preserve_first_candidates(reg)
    reg = mark_from_benchmark(reg)
    save_json(REGISTRY, reg)
    print(json.dumps({"registry": str(REGISTRY), "models": len(reg["models"])}, indent=2))


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Preserve-first Hermes model registry and selector.")
    parser.add_argument("command", choices=["refresh-registry", "select", "maintain", "classify"])
    parser.add_argument("--task-class", default="LOCAL_SIMPLE")
    parser.add_argument("--task", default="")
    args = parser.parse_args()

    if args.command in {"refresh-registry", "maintain"}:
        refresh_registry()
    elif args.command == "select":
        print(json.dumps(select(args.task_class), ensure_ascii=False, indent=2))
    elif args.command == "classify":
        text = args.task.lower()
        if any(w in text for w in ["codex", "chatgpt"]):
            cls = "CODEX_HEAVY"
        elif any(w in text for w in ["summarize", "title", "rename", "compress"]):
            cls = "AUXILIARY"
        elif any(w in text for w in ["research", "browse", "web", "sources", "latest"]):
            cls = "RESEARCH"
        elif any(w in text for w in ["prove", "reason", "architecture", "design decision"]):
            cls = "REASONING"
        elif any(w in text for w in ["property", "real estate", "supabase", "listing"]):
            cls = "REAL_ESTATE"
        elif any(w in text for w in ["bug", "test", "implement", "code", "refactor", "fix"]):
            cls = "CODING"
        else:
            cls = "LOCAL_SIMPLE"
        print(json.dumps({"task_class": cls}, ensure_ascii=False))


if __name__ == "__main__":
    main()
