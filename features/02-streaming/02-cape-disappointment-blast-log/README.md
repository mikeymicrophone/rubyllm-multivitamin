# Streaming · 02 · Cape Disappointment blast log

The foghorn watch at Cape Disappointment calls the posted card into the
log as each chunk arrives, then calls it again. The second pass is the
cassette playing the same SSE body back.

**What it teaches**

- Each non-empty `chunk.content` is written to an IO, then flushed, so a
  terminal shows the card as the stream is parsed.
- `with_thinking(false)` sends `"reasoning":{"enabled":false}`. The log
  does not collect reasoning chunks.
- Passing a block sets `"stream":true` and
  `"stream_options":{"include_usage":true}` on the Chat Completions body.
- The response `Content-Type` is `text/event-stream`. The body is `data:`
  lines and a closing `data: [DONE]`.
- A second `ask` with the same card yields the same pieces. Replay does
  not call OpenRouter.

**Files**

| File | Role |
| --- | --- |
| [`blast_log.rb`](blast_log.rb) | Calls the card twice, writing each spoken chunk to the log |
| [`blast_log_test.rb`](blast_log_test.rb) | Replays both passes and checks the SSE body |
| [`cassettes/blast_log.yml`](cassettes/blast_log.yml) | The two streamed round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/02-cape-disappointment-blast-log/blast_log.rb
bundle exec ruby features/02-streaming/02-cape-disappointment-blast-log/blast_log_test.rb
```

Both commands replay the cassette. No API key is required. The script
writes the card twice because the cassette holds two passes.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with the test, so both passes are written:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/02-cape-disappointment-blast-log/blast_log_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written. When the SSE body contains
bytes above 127, VCR stores it as YAML `!binary`. `YAML.load_file` returns
that body, and forcing UTF-8 shows the `data:` lines.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
