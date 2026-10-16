# Hosted research · 08 · Rapa Nui moai budget

A Rapa Nui conservation researcher keeps a budget-limited coastal erosion report and explicitly marks its unresolved work. The fixture supplies budget_exceeded; no undocumented budget option is sent.

**What it teaches**

- budget_exceeded becomes incomplete; wait returns a usable partial Message.
- case/in destructures a task receipt and marks max_tokens output for follow-up.

**Files**

| File | Role |
| --- | --- |
| [`moai_budget.rb`](moai_budget.rb) | Hosted research workflow and Ruby idioms |
| [`moai_budget_test.rb`](moai_budget_test.rb) | Offline behavior and wire assertions |
| [`cassettes/moai_budget.yml`](cassettes/moai_budget.yml) | Hand-authored Vertex Interactions responses |

**Try it**

```sh
bundle exec ruby features/32-hosted-research/08-rapa-nui-moai-budget/moai_budget.rb
bundle exec ruby features/32-hosted-research/08-rapa-nui-moai-budget/moai_budget_test.rb
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
