# Free Model Scout

## Implemented

- Script: `scripts/free-model-scout.py`.
- Outputs:
  - `free-model-scout.json`
  - `free-model-scout.md`

## Behavior

- Queries OpenRouter official model catalog.
- Queries local LM Studio `/models`.
- Selects models whose provider-reported prompt and completion prices are both zero.
- Records provider, model ID, context length, tool support if known, reasoning support if known, vision support if known, price, availability, timestamp.
- Does not change Hermes routing.

## Latest Run

- Found 27 zero-price/local candidates.
- Providers found: `openrouter`, `lmstudio`.

## Benchmark

- Script: `scripts/model-benchmark.py`.
- Max 5 models, sequential, max 16 response tokens.
- Uses only OpenRouter models ending in `:free`.

Latest benchmark:

| Model | Result | Latency |
|---|---|---:|
| `cohere/north-mini-code:free` | ok | 21741 ms |
| `dots-studio/dots-3-note-preview:free` | ok | 22448 ms |
| `google/gemma-4-26b-a4b-it:free` | 429 rate limited | |
| `google/gemma-4-31b-it:free` | 429 rate limited | |
| `inclusionai/ling-3.0-flash-fin:free` | ok | 905 ms |

Fastest successful candidate observed: `inclusionai/ling-3.0-flash-fin:free`.
