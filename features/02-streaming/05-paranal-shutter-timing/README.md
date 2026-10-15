# Streaming · 05 · Paranal shutter timing

The night astronomer at Cerro Paranal times the UT1 Nasmyth shutter: open
0.4 seconds, closed 9.6 seconds. The control phone speaks only the chunks
that carry words. A second timing is capped at 16 output tokens so the
relief hears a clipped fragment.

**What it teaches**

- Chunks with an empty `content` are not appended to the spoken timing.
  Reasoning-only chunks, when they arrive, carry the delta on
  `thinking.text` instead.
- Joining the spoken pieces reproduces the returned message.
- `with_max_output_tokens(16)` is `"max_output_tokens":16` on OpenAI
  Responses (`"max_tokens"` on Chat Completions). The stream can finish
  with `finish_reason` `:max_tokens` and a short or empty `content`.
  `ask` returns that message. It does not raise.

**Files**

| File | Role |
| --- | --- |
| [`shutter_timing.rb`](shutter_timing.rb) | Streams the open timing, then the capped timing |
| [`shutter_timing_test.rb`](shutter_timing_test.rb) | Replays both and checks the clipped note |
| [`cassettes/shutter_timing.yml`](cassettes/shutter_timing.yml) | The two streamed timings |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/05-paranal-shutter-timing/shutter_timing.rb
bundle exec ruby features/02-streaming/05-paranal-shutter-timing/shutter_timing_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/05-paranal-shutter-timing/shutter_timing_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
