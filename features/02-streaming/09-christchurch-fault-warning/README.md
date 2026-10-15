# Streaming · 09 · Christchurch Alpine Fault warning

The civic desk in Christchurch copies a shaking warning: intensity 8 and
35 schools closed on the Alpine Fault. The name of the fault is read after
the chunks are joined. First-token latency is the clock until the first
spoken chunk, not until a leading reasoning delta.

**What it teaches**

- `Alpine Fault` is matched on the joined speech. A chunk may hold only
  part of the name. `[[:space:]]` matches a normal space or U+202F.
- First-token latency is the monotonic clock from the start of `ask` until
  the first chunk whose `content` is non-empty.
- Chunks before that index have empty `content`. On a reasoning model at
  least one of them carries `thinking.text`. `gpt-4.1-mini` often speaks
  on the first chunk.
- A cassette replay yields those chunks from the recorded body, so the
  measured seconds are parse time. The test checks the order of the clock,
  not a live network delay.

**Files**

| File | Role |
| --- | --- |
| [`fault_warning.rb`](fault_warning.rb) | Streams the warning and times the first spoken chunk |
| [`fault_warning_test.rb`](fault_warning_test.rb) | Replays the cassette and checks the join and the clock |
| [`cassettes/fault_warning.yml`](cassettes/fault_warning.yml) | The streamed warning |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning.rb
bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/09-christchurch-fault-warning/fault_warning_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
