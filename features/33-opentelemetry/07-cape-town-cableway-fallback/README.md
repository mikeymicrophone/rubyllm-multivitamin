# OpenTelemetry · 07 · Cape Town cableway fallback

The Table Mountain cableway clerk hits an OpenRouter rate limit and gets the wind-hold brief from the OpenAI spare. Both model attempts belong to one dispatch workflow.

**What it teaches**

- A proc receives before_fallback; method(:name) is passed with &.
- A cross-provider fallback creates a new model span.
- The failed attempt retains error.type while the spare returns the brief.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`cableway_fallback.rb`](cableway_fallback.rb) | Runs the scenario and prints its trace |
| [`cableway_fallback_test.rb`](cableway_fallback_test.rb) | Checks the result and trace relationships |
| [`cassettes/cableway_fallback.yml`](cassettes/cableway_fallback.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/07-cape-town-cableway-fallback/cableway_fallback.rb
bundle exec ruby features/33-opentelemetry/07-cape-town-cableway-fallback/cableway_fallback_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Request bodies were
built by running the pinned RubyLLM 2.1.1 encoder; responses use the provider's
JSON shape (SSE for the stream). Counts and replies are illustrative fixture
values, not measurements of a live provider. No span IDs or timestamps are
fixtures: the real OpenTelemetry SDK creates every span during replay.

Re-record with `LIVE=1 OPENROUTER_API_KEY=... OPENAI_API_KEY=...`.

**Model**

OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`, then OpenAI `gpt-4.1-mini`.
