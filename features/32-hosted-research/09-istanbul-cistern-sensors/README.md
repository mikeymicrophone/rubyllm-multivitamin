# Hosted research · 09 · Istanbul cistern sensors

An Istanbul cistern archivist combines public heritage research with a narrow Microsoft Learn tool allowlist. Allowed remote tools run without local approval.

**What it teaches**

- allowed_tools constrains hosted MCP discovery; web_search and MCP can coexist.
- A tool manifest and `filter_map` retain named remote calls in a fluent pipeline.

**Files**

| File | Role |
| --- | --- |
| [`cistern_sensors.rb`](cistern_sensors.rb) | Hosted research workflow and Ruby idioms |
| [`cistern_sensors_test.rb`](cistern_sensors_test.rb) | Offline behavior and wire assertions |
| [`cassettes/cistern_sensors.yml`](cassettes/cistern_sensors.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/09-istanbul-cistern-sensors/cistern_sensors.rb
bundle exec ruby features/32-hosted-research/09-istanbul-cistern-sensors/cistern_sensors_test.rb
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
