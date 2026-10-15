# Streaming · 06 · Kigali drone corridor check

The medical dispatcher Amahoro calls Kigali International on corridor 66.
The tower streams the check into the log, then reads the token counts.
Those counts are on the last chunk.

**What it teaches**

- A block on `ask` streams the reply. Chat Completions also sends
  `stream_options: { include_usage: true }`.
- Every chunk before the last one has nil `tokens.input`. On Chat
  Completions an earlier chunk can already carry `finish_reason` with
  nil tokens. On OpenAI Responses the finish reason typically arrives
  with the usage chunk.
- The last chunk carries `tokens.input`, `tokens.output`, and
  `tokens.thinking`. The returned message matches it.
- `cost.total` is the provider's reported cost.

**Files**

| File | Role |
| --- | --- |
| [`corridor_check.rb`](corridor_check.rb) | Streams the check and notes each chunk's tokens |
| [`corridor_check_test.rb`](corridor_check_test.rb) | Replays the cassette and checks the usage chunk |
| [`cassettes/corridor_check.yml`](cassettes/corridor_check.yml) | The streamed corridor check |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/06-kigali-corridor-check/corridor_check.rb
bundle exec ruby features/02-streaming/06-kigali-corridor-check/corridor_check_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/06-kigali-corridor-check/corridor_check_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
