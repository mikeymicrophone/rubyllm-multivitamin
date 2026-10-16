# OpenTelemetry · 05 · Venice Rialto sealed manifest

A Rialto receiving clerk keeps a sealed merchant reference in the request while the tracing exporter receives only operation metadata. An existing instrumenter still observes the full application event.

**What it teaches**

- RubyLLM.context isolates an instrumenter and provider settings.
- A lambda observes chat events without replacing the tracing subscriber.
- Workflow metadata, prompts, headers, provider options, and replies stay out of exported spans.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`sealed_manifest.rb`](sealed_manifest.rb) | Runs the scenario and prints its trace |
| [`sealed_manifest_test.rb`](sealed_manifest_test.rb) | Checks the result and trace relationships |
| [`cassettes/sealed_manifest.yml`](cassettes/sealed_manifest.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/05-venice-rialto-sealed-manifest/sealed_manifest.rb
bundle exec ruby features/33-opentelemetry/05-venice-rialto-sealed-manifest/sealed_manifest_test.rb
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
