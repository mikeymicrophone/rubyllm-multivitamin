# OpenTelemetry · 03 · Zanzibar Stone Town tide steps

The landing clerk reads a posted tide tool, then stops at the tool result for a human landing decision. Tool execution and model generation are siblings beneath the workflow step.

**What it teaches**

- Class and instance tools share registration; a block declares the tide schema.
- ask_later, generate, then run_tools deliberately stop before another ask.
- execute_tool is an internal child of the active workflow step, beside chat.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`tide_steps.rb`](tide_steps.rb) | Runs the scenario and prints its trace |
| [`tide_steps_test.rb`](tide_steps_test.rb) | Checks the result and trace relationships |
| [`cassettes/tide_steps.yml`](cassettes/tide_steps.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/03-zanzibar-stone-town-steps/tide_steps.rb
bundle exec ruby features/33-opentelemetry/03-zanzibar-stone-town-steps/tide_steps_test.rb
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
