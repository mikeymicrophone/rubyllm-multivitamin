# Hosted research · 04 · Valparaíso funicular sources

A Valparaíso heritage editor groups source labels and verifies that accented text does not shift the cited spans.

**What it teaches**

- A scoped refinement formats Citation objects without changing the gem globally.
- each_with_object groups sources; UTF-8 citation byte offsets become character spans.

**Files**

| File | Role |
| --- | --- |
| [`funicular_sources.rb`](funicular_sources.rb) | Hosted research workflow and Ruby idioms |
| [`funicular_sources_test.rb`](funicular_sources_test.rb) | Offline behavior and wire assertions |
| [`cassettes/funicular_sources.yml`](cassettes/funicular_sources.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/04-valparaiso-funicular-sources/funicular_sources.rb
bundle exec ruby features/32-hosted-research/04-valparaiso-funicular-sources/funicular_sources_test.rb
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
