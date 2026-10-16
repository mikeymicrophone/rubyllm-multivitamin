# OpenTelemetry · 04 · Machu Picchu terrace drains

The terrace crew groups drainage inspections and a nested repair tally in one workflow. Every step is ordinary Ruby; tracing does not require a model call.

**What it teaches**

- A table drives nested workflow steps with stable safe IDs.
- each_with_object builds a repair ledger; step returns the block value.
- Trace and parent IDs describe the tree independently of finish order.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`terrace_drains.rb`](terrace_drains.rb) | Runs the scenario and prints its trace |
| [`terrace_drains_test.rb`](terrace_drains_test.rb) | Checks the result and trace relationships |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/04-machu-picchu-terrace-drains/terrace_drains.rb
bundle exec ruby features/33-opentelemetry/04-machu-picchu-terrace-drains/terrace_drains_test.rb
```

**Fixture provenance**

This scenario makes **no HTTP calls** and has no provider cassette. It runs
ordinary Ruby inside real SDK spans; no span fixtures are needed.

**Model**

None; local workflow operations only.
