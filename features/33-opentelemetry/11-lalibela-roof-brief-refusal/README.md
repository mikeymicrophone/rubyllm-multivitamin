# OpenTelemetry · 11 · Lalibela roof brief refusal

A Lalibela roof-inspection desk accidentally asks for an invalid sampling temperature. The provider refusal marks the chat, step, and workflow as errors before the desk catches it.

**What it teaches**

- A provider exception passes through workflow and step boundaries.
- error.type and error status are exported without exception text or events.
- Rescue outside the workflow preserves the failed tree and returns a typed refusal.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`roof_refusal.rb`](roof_refusal.rb) | Runs the scenario and prints its trace |
| [`roof_refusal_test.rb`](roof_refusal_test.rb) | Checks the result and trace relationships |
| [`cassettes/roof_refusal.yml`](cassettes/roof_refusal.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/11-lalibela-roof-brief-refusal/roof_refusal.rb
bundle exec ruby features/33-opentelemetry/11-lalibela-roof-brief-refusal/roof_refusal_test.rb
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
