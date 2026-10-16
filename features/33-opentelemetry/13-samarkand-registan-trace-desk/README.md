# OpenTelemetry · 13 · Samarkand Registan trace desk

A Registan conservation agent reads the tile cart, issues a structured dispatch, then takes a changed unloading time. Both turns and the tool run stay beneath named workflow steps.

**What it teaches**

- An Agent declares model, tools, instructions, and a structured-output schema.
- A table of turns and an explicit generate/run_tools loop expose model boundaries.
- Workflow steps, tool spans, JSON output type, usage, and transcript history meet in one trace.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`registan_desk.rb`](registan_desk.rb) | Runs the scenario and prints its trace |
| [`registan_desk_test.rb`](registan_desk_test.rb) | Checks the result and trace relationships |
| [`cassettes/registan_desk.yml`](cassettes/registan_desk.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/13-samarkand-registan-trace-desk/registan_desk.rb
bundle exec ruby features/33-opentelemetry/13-samarkand-registan-trace-desk/registan_desk_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Request bodies were
built by running the pinned RubyLLM 2.1.1 encoder; responses use the provider's
JSON shape (SSE for the stream). Counts and replies are illustrative fixture
values, not measurements of a live provider. No span IDs or timestamps are
fixtures: the real OpenTelemetry SDK creates every span during replay.

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`.
