# OpenTelemetry · 01 · Kyoto Fushimi lantern watch

A lantern keeper at Fushimi Inari briefs the relief from a posted repair card. The chat exists before tracing starts; enabling twice must still export one model span.

**What it teaches**

- An instance owns a chat created before enable.
- Configure the SDK before enabling; repeated enable is harmless.
- A real ask exports one span and leaves the answer intact.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`lantern_watch.rb`](lantern_watch.rb) | Runs the scenario and prints its trace |
| [`lantern_watch_test.rb`](lantern_watch_test.rb) | Checks the result and trace relationships |
| [`cassettes/lantern_watch.yml`](cassettes/lantern_watch.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/01-kyoto-fushimi-lanterns/lantern_watch.rb
bundle exec ruby features/33-opentelemetry/01-kyoto-fushimi-lanterns/lantern_watch_test.rb
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
