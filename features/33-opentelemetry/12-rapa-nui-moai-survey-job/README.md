# OpenTelemetry · 12 · Rapa Nui moai survey job

A moai survey dispatcher serializes W3C trace context into a job envelope. An application-created worker thread extracts it before opening a workflow and briefing the survey team.

**What it teaches**

- An immutable job envelope survives a JSON round trip.
- TraceContext inject/extract explicitly propagates an application-created thread.
- The worker workflow joins its dispatch parent; RubyLLM does not propagate arbitrary jobs automatically.

Uses the shared [runtime](../../../support/runtime.rb) and
[tracing capture](../../../support/tracing.rb). The capture owns the temporary
provider and subscription, snapshots spans before shutdown, and restores the
previous process provider on exit. No OTLP collector is needed.

**Files**

| File | Role |
| --- | --- |
| [`survey_job.rb`](survey_job.rb) | Runs the scenario and prints its trace |
| [`survey_job_test.rb`](survey_job_test.rb) | Checks the result and trace relationships |
| [`cassettes/survey_job.yml`](cassettes/survey_job.yml) | Hand-authored provider response fixture |

**Try it**

```sh
bundle exec ruby features/33-opentelemetry/12-rapa-nui-moai-survey-job/survey_job.rb
bundle exec ruby features/33-opentelemetry/12-rapa-nui-moai-survey-job/survey_job_test.rb
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
