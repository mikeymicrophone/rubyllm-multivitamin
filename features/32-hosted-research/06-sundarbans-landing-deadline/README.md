# Hosted research · 06 · Sundarbans landing deadline

A Sundarbans landing planner preserves the remote ID when a collection deadline expires, then resumes the same task. The test advances a monotonic clock; it does not sleep to cause a timeout.

**What it teaches**

- job.wait timeout retains the independent pending job through error.job.
- An instance separates submission, collection, and recovery; rescue does not cancel.

**Files**

| File | Role |
| --- | --- |
| [`landing_deadline.rb`](landing_deadline.rb) | Hosted research workflow and Ruby idioms |
| [`landing_deadline_test.rb`](landing_deadline_test.rb) | Offline behavior and wire assertions |
| [`cassettes/landing_deadline.yml`](cassettes/landing_deadline.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/06-sundarbans-landing-deadline/landing_deadline.rb
bundle exec ruby features/32-hosted-research/06-sundarbans-landing-deadline/landing_deadline_test.rb
```

**Fixture provenance and live runs**

This cassette is **hand-authored**, not a live recording. Requests were captured
from this script through the pinned RubyLLM 2.1.1 encoder with WebMock; response
bodies were authored in the Vertex Interactions shape. Reports, tool traces,
usage, citations, and remote IDs are illustrative scaffolding, not verified
research or observations of the live service.

Replay needs no credentials or `googleauth`. The shared cassette player scopes
a placeholder Vertex authorization header to replay and restores the original
provider method afterward. Request matching remains method, URI, and body.

To replace the fixture, add `googleauth` to your local bundle, configure Google
Application Default Credentials with research access, and run this script with
`LIVE=1 GOOGLE_CLOUD_PROJECT=your-project` (leave `LIVE_PROVIDER` unset). Live
uses real ADC; the player filters bearer credentials. The hosted agent is
`deep-research-preview-04-2026`, separate from any inference model; there is
no free OpenRouter equivalent. See the [feature README](../README.md).

This uses `job.wait`, which leaves the task running on timeout. Blocking
`RubyLLM.research` instead attempts cancellation when it raises.
