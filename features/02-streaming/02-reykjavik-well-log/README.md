# Streaming · 02 · Reykjavík geothermal well log

The well tender at Hellisheiði Power Plant outside Reykjavík calls the
posted pulse card into the log as each chunk arrives. Playing the cassette
again yields the same pieces.

**What it teaches**

- Each non-empty `chunk.content` is written to an IO, then flushed, so a
  terminal shows the card as the stream is parsed.
- `Multivitamin::Models.quiet_thinking` sends `"reasoning":{"enabled":false}`
  on OpenRouter. On `gpt-4.1-mini` that call is a no-op (`with_thinking(false)`
  raises), and the log still collects no thinking chunks.
- Passing a block sets `"stream":true`. OpenAI Responses streams
  `response.output_text.delta` events. Chat Completions also sends
  `stream_options: { include_usage: true }` and a closing `data: [DONE]`.
- The response `Content-Type` is `text/event-stream`. The body is `data:`
  lines.
- A second play of that cassette yields the same pieces. The live model
  does not: two recordings of this card were not the same words, so the
  test compares replays, not two live calls.

**Files**

| File | Role |
| --- | --- |
| [`well_log.rb`](well_log.rb) | Writes each spoken chunk to the log |
| [`well_log_test.rb`](well_log_test.rb) | Replays the cassette twice and checks the SSE body |
| [`cassettes/well_log.yml`](cassettes/well_log.yml) | The streamed card |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/02-reykjavik-well-log/well_log.rb
bundle exec ruby features/02-streaming/02-reykjavik-well-log/well_log_test.rb
```

Both commands replay the cassette. No API key is required. The test plays
the cassette a second time and checks that the pieces match.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with the test. `LIVE=1` writes one interaction; the second
play in the test runs only on replay.

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/02-reykjavik-well-log/well_log_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-` token before the file is written. This SSE body is ASCII, so
the `data:` lines are plain YAML. A body that contains a character above
127, such as the date-pack dictation, is stored as `!binary` instead.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
