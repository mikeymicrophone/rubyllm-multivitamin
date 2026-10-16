# Hosted research · 10 · Okavango water ledger

An Okavango map archivist records token buckets without pricing the hosted agent as a chat model. The synthetic usage includes cached and tool input plus thoughts inside output.

**What it teaches**

- Agent usage does not borrow inference-model pricing; unknown cost stays nil.
- zip, sum, and numbered parameters build a ledger without double-counting thoughts.

**Files**

| File | Role |
| --- | --- |
| [`water_ledger.rb`](water_ledger.rb) | Hosted research workflow and Ruby idioms |
| [`water_ledger_test.rb`](water_ledger_test.rb) | Offline behavior and wire assertions |
| [`cassettes/water_ledger.yml`](cassettes/water_ledger.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/10-okavango-water-ledger/water_ledger.rb
bundle exec ruby features/32-hosted-research/10-okavango-water-ledger/water_ledger_test.rb
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
