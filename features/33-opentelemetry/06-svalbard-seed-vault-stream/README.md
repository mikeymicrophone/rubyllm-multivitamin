# OpenTelemetry · 06 · Svalbard seed vault stream

A Longyearbyen vault clerk streams a cold-room transfer brief. The callback checks that the model span is still current and has not reached the synchronous exporter.

**What it teaches**

- A block on ask streams an OpenRouter brief with thinking disabled.
- filter_map selects spoken chunks; callbacks inspect the live span context.
- The completed span carries stream=true and the final usage.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`vault_stream.rb`](vault_stream.rb) | Runs the scenario and prints its trace |
| [`vault_stream_test.rb`](vault_stream_test.rb) | Checks the result and trace relationships |
| [`cassettes/vault_stream.yml`](cassettes/vault_stream.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/06-svalbard-seed-vault-stream/vault_stream.rb
bundle exec ruby features/33-opentelemetry/06-svalbard-seed-vault-stream/vault_stream_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Request bodies were
built by running the pinned RubyLLM 2.1.1 encoder; responses use the provider's
JSON shape (SSE for the stream). Counts and replies are illustrative fixture
values, not measurements of a live provider. No span IDs or timestamps are
fixtures: the real OpenTelemetry SDK creates every span during replay.

Re-record with `LIVE=1 OPENROUTER_API_KEY=...`.

**Model**

OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`.
