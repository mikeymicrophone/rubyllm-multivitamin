# Hosted research · 11 · Lalibela roof recovery

A Lalibela conservation desk resumes yesterday’s saved roof-shelter study from a JSON receipt, without submitting or billing a duplicate task.

**What it teaches**

- ResearchJob.find recovers a saved remote ID in the original provider context.
- JSON receipt destructuring and a lazy citation pipeline avoid a second submission.

**Files**

| File | Role |
| --- | --- |
| [`roof_recovery.rb`](roof_recovery.rb) | Hosted research workflow and Ruby idioms |
| [`roof_recovery_test.rb`](roof_recovery_test.rb) | Offline behavior and wire assertions |
| [`cassettes/roof_recovery.yml`](cassettes/roof_recovery.yml) | Hand-authored Vertex Interactions responses |
| [`fixtures/roof-receipt.json`](fixtures/roof-receipt.json) | Hand-authored saved job ID for replay |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/11-lalibela-roof-recovery/roof_recovery.rb
bundle exec ruby features/32-hosted-research/11-lalibela-roof-recovery/roof_recovery_test.rb
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

For live recovery, pass the path of a receipt containing a real `job_id` and
`"provider": "vertexai"` as the script’s first argument, using the same project
as the original submission. The supplied receipt works only for replay.
