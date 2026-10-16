# OpenTelemetry · 10 · Ilulissat icefjord index

The icefjord visitor desk embeds three route notices in one call, groups the finished export by operation, then clears the exporter while retaining a snapshot for its ledger.

**What it teaches**

- An enumerator and lazy pipeline prepare a batch embedding; numbered block parameters tally operations.
- A refinement names a span operation without changing String globally.
- An in-memory exporter supports snapshots and reset; embeddings carry dimension and input usage.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`icefjord_index.rb`](icefjord_index.rb) | Runs the scenario and prints its trace |
| [`icefjord_index_test.rb`](icefjord_index_test.rb) | Checks the result and trace relationships |
| [`cassettes/icefjord_index.yml`](cassettes/icefjord_index.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/10-ilulissat-icefjord-index/icefjord_index.rb
bundle exec ruby features/33-opentelemetry/10-ilulissat-icefjord-index/icefjord_index_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Request bodies were
built by running the pinned RubyLLM 2.1.1 encoder; responses use the provider's
JSON shape (SSE for the stream). Counts and replies are illustrative fixture
values, not measurements of a live provider. No span IDs or timestamps are
fixtures: the real OpenTelemetry SDK creates every span during replay.

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `text-embedding-3-small` with three output dimensions.
