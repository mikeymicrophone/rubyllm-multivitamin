# Hosted research · 05 · Petra sandstone survey

A Petra surveyor attaches a small, fictional field-survey PDF and preserves its file citation and page number.

**What it teaches**

- with: attaches a local PDF inline as a document, not as a prompt filename.
- A customized Data record pairs file citations and page numbers with a report.

**Files**

| File | Role |
| --- | --- |
| [`sandstone_survey.rb`](sandstone_survey.rb) | Hosted research workflow and Ruby idioms |
| [`sandstone_survey_test.rb`](sandstone_survey_test.rb) | Offline behavior and wire assertions |
| [`cassettes/sandstone_survey.yml`](cassettes/sandstone_survey.yml) | Hand-authored Vertex Interactions responses |
| [`fixtures/sandstone-survey.pdf`](fixtures/sandstone-survey.pdf) | Hand-authored fictional field survey |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/05-petra-sandstone-survey/sandstone_survey.rb
bundle exec ruby features/32-hosted-research/05-petra-sandstone-survey/sandstone_survey_test.rb
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
