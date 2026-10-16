# Hosted research · 03 · Nairobi railway archive

A Nairobi railway archive asks the provider to research an ingestion design through Microsoft Learn MCP; no local MCP client runs.

**What it teaches**

- A context submits hosted MCP research; name and url remain Vertex MCP fields.
- A proc builds a documentation brief; remote calls appear on server_tool_calls.

**Files**

| File | Role |
| --- | --- |
| [`railway_archive.rb`](railway_archive.rb) | Hosted research workflow and Ruby idioms |
| [`railway_archive_test.rb`](railway_archive_test.rb) | Offline behavior and wire assertions |
| [`cassettes/railway_archive.yml`](cassettes/railway_archive.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/03-nairobi-railway-archive/railway_archive.rb
bundle exec ruby features/32-hosted-research/03-nairobi-railway-archive/railway_archive_test.rb
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
