# Hosted research · 07 · Reykjavík heat cancel

A Reykjavík archive desk withdraws a duplicate heating study and retains the cancellation confirmation instead of reading a nonexistent report.

**What it teaches**

- cancel requests a remote transition; cancelled message raises an error retaining the job.
- A lambda captures an audit snapshot before and after provider confirmation.

**Files**

| File | Role |
| --- | --- |
| [`heat_cancel.rb`](heat_cancel.rb) | Hosted research workflow and Ruby idioms |
| [`heat_cancel_test.rb`](heat_cancel_test.rb) | Offline behavior and wire assertions |
| [`cassettes/heat_cancel.yml`](cassettes/heat_cancel.yml) | Hand-authored Vertex Interactions responses |
| [`cassettes/heat_pending.yml`](cassettes/heat_pending.yml) | Hand-authored cancellation still pending |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/07-reykjavik-heat-cancel/heat_cancel.rb
bundle exec ruby features/32-hosted-research/07-reykjavik-heat-cancel/heat_cancel_test.rb
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

Cancellation is a request: this fixture confirms `cancelled`. A live service
may return a pending transition; do not assume the cancellation was confirmed.
