# OpenTelemetry · 09 · Dubrovnik wall watch

The wall crew disables RubyLLM tracing during an active inspection. New workflow operations stop exporting, the current workflow finishes, and the SDK remains usable for the application.

**What it teaches**

- An explicit watch loop crosses enable/disable boundaries.
- disable stops new operations while an already running span finishes.
- The application tracer remains usable; disable never shuts down its SDK.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`wall_watch.rb`](wall_watch.rb) | Runs the scenario and prints its trace |
| [`wall_watch_test.rb`](wall_watch_test.rb) | Checks the result and trace relationships |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/09-dubrovnik-wall-watch/wall_watch.rb
bundle exec ruby features/33-opentelemetry/09-dubrovnik-wall-watch/wall_watch_test.rb
```

**Fixture provenance**

This scenario makes **no HTTP calls** and has no provider cassette. It runs
ordinary Ruby inside real SDK spans; no span fixtures are needed.

**Model**

None; local workflow operations only.
