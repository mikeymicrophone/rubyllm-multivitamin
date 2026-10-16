# OpenTelemetry · 02 · Petra Siq water gate

The Siq gate clerk turns a channel inspection into a short opening brief and reconciles the model span with the message token ledger.

**What it teaches**

- A customized immutable Data record totals token buckets with zip and sum.
- A fluent chat sets temperature and output cap, visible on the client span.
- Requested and response model IDs differ; reported zero cache counts stay present.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`water_gate.rb`](water_gate.rb) | Runs the scenario and prints its trace |
| [`water_gate_test.rb`](water_gate_test.rb) | Checks the result and trace relationships |
| [`cassettes/water_gate.yml`](cassettes/water_gate.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/02-petra-siq-water-gate/water_gate.rb
bundle exec ruby features/33-opentelemetry/02-petra-siq-water-gate/water_gate_test.rb
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
