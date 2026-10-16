# OpenTelemetry · 08 · Angkor Wat causeway trials

A causeway inspection evaluation checks two posted repair sections. Each trial becomes its own workflow with perform and evaluate steps; Ruby assertions grade the briefs locally.

**What it teaches**

- Evaluation trials create workflows without a manual workflow wrapper.
- A YAML dataset supplies structured inputs; case/in destructures the inspection.
- evaluator false retains Ruby assertions and avoids a second model grader.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`causeway_trials.rb`](causeway_trials.rb) | Runs the scenario and prints its trace |
| [`causeway_trials_test.rb`](causeway_trials_test.rb) | Checks the result and trace relationships |
| [`cassettes/causeway_trials.yml`](cassettes/causeway_trials.yml) | Hand-authored provider response fixture |
| [`causeway_cards.yml`](causeway_cards.yml) | Posted inspection cases |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/08-angkor-wat-causeway-trials/causeway_trials.rb
bundle exec ruby features/33-opentelemetry/08-angkor-wat-causeway-trials/causeway_trials_test.rb
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
