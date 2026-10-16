# Hosted research · 02 · Samarkand mosaic watch

A Registan conservation desk owns the remote job, records queued/running/complete transitions, and refuses to poll forever.

**What it teaches**

- An instance owns a research_later job and polls refresh in a bounded loop.
- An Enumerator records state transitions; pending message is nil and refresh returns self.

**Files**

| File | Role |
| --- | --- |
| [`mosaic_watch.rb`](mosaic_watch.rb) | Hosted research workflow and Ruby idioms |
| [`mosaic_watch_test.rb`](mosaic_watch_test.rb) | Offline behavior and wire assertions |
| [`cassettes/mosaic_watch.yml`](cassettes/mosaic_watch.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/02-samarkand-mosaic-watch/mosaic_watch.rb
bundle exec ruby features/32-hosted-research/02-samarkand-mosaic-watch/mosaic_watch_test.rb
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
