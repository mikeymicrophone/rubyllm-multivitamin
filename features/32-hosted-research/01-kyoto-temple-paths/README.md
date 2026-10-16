# Hosted research · 01 · Kyoto temple paths

A Kyoto walking-route editor compares two temple approaches and keeps the sources beside the conservation briefing.

**What it teaches**

- Blocking research returns a Message, with a hosted agent rather than a model.
- Data.define records and module functions turn a cited report into a route card.

**Files**

| File | Role |
| --- | --- |
| [`temple_paths.rb`](temple_paths.rb) | Hosted research workflow and Ruby idioms |
| [`temple_paths_test.rb`](temple_paths_test.rb) | Offline behavior and wire assertions |
| [`cassettes/temple_paths.yml`](cassettes/temple_paths.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/01-kyoto-temple-paths/temple_paths.rb
bundle exec ruby features/32-hosted-research/01-kyoto-temple-paths/temple_paths_test.rb
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
