# Hosted research · 13 · Iguazú trail research desk

An Iguazú desk runs separate Argentine and Brazilian trail studies, then groups cited sources into one handover while retaining both remote job IDs.

**What it teaches**

- A capstone submits a table of tasks, waits, and retains IDs for failed work.
- Data records, &method(:collect), find patterns, and source grouping build a desk handover.

**Files**

| File | Role |
| --- | --- |
| [`trail_desk.rb`](trail_desk.rb) | Hosted research workflow and Ruby idioms |
| [`trail_desk_test.rb`](trail_desk_test.rb) | Offline behavior and wire assertions |
| [`cassettes/trail_desk.yml`](cassettes/trail_desk.yml) | Hand-authored Vertex Interactions responses |
| [`cassettes/trail_failed.yml`](cassettes/trail_failed.yml) | Hand-authored retrieval failure with a sibling task still pending |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/13-iguazu-trail-research-desk/trail_desk.rb
bundle exec ruby features/32-hosted-research/13-iguazu-trail-research-desk/trail_desk_test.rb
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
