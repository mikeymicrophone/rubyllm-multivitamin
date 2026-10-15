# Structured output · 10 · Windhoek HF skip board

The skip watch at the Windhoek radio club streams the HF board into a schema: southwest, 18 MHz, peaks 24.

**What it teaches**

- `ask` with a block streams a schema. The request sets `"stream": true`.
- Chunks are pieces of the JSON text. Joining them equals `message.content`.
- The SSE event is `response.output_text.delta`.
- `message.parsed` is the Hash. Its keys are strings. Megahertz and peaks are integers.

**Files**

| File | Role |
| --- | --- |
| [`skip_report.rb`](skip_report.rb) | Streams the skip report |
| [`skip_report_test.rb`](skip_report_test.rb) | Replays the cassette |
| [`cassettes/skip_report.yml`](cassettes/skip_report.yml) | Live recording of the streamed schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/10-windhoek-hf-skip/skip_report_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/10-windhoek-hf-skip/skip_report_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
