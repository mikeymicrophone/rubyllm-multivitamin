# Hosted research

`RubyLLM.research` submits a single-turn hosted agent task, waits, and returns a
`RubyLLM::Message` with content, citations, thinking, and server tool traces.
`agent:` identifies the hosted agent, separate from an inference model ID or a
`RubyLLM::Agent` class. `research_later` returns a `RubyLLM::ResearchJob` immediately.

Official reference: [Hosted Research](https://rubyllm.com/hosted-research/).
The scripts and fixture encodings were checked against the installed 2.1.1 source.

## RubyLLM 2.1.1 entry points

- `RubyLLM.research(prompt, provider: :vertexai, agent:, context:)`
- `context.research` and `context.research_later`
- `ResearchJob.find(id, provider: :vertexai, context:)`
- `job.refresh`, `wait(timeout:, interval:)`, `message`, and `cancel`
- `pending?`, `completed?`, `incomplete?`, `failed?`, and `cancelled?`
- `job.tokens`, `cost`, `raw`, `error`, and errors retaining `error.job`
- `provider_tools: [:web_search]` or `{ mcp: { name:, url:, allowed_tools: } }`
- `with:` for an image or PDF; `provider_tools: []` sends an empty tools array

`job.wait` timeout leaves the task running. Blocking `RubyLLM.research` attempts
cancellation when it times out or is interrupted; inspect `error.job` and
`job.cancellation_error` rather than assuming the cancellation succeeded.
Incomplete and budget-exceeded tasks retain a report with `finish_reason`
`:max_tokens`. Failed or cancelled tasks raise on `wait` and `message`.

## Providers and fixture provenance

All HTTP scenarios use Vertex AI Interactions with the hosted agent
`deep-research-preview-04-2026` and `vertexai_location = "global"`. OpenAI
background Responses, Gemini chat, and local RubyLLM agents are separate APIs.
There is no free OpenRouter hosted-research agent. `LIVE_PROVIDER` does not
retarget research, so leave it unset when recording this feature.

**All cassettes are hand-authored, not live recordings.** Twelve scenarios make
HTTP calls; Reykjavík and Iguazú also include alternate lifecycle fixtures. Each
request body was captured by running the script through RubyLLM 2.1.1's encoder with
WebMock blocking the network. Responses use the real parser's Vertex
Interactions shape: `id`, `agent`, `status`, `steps`, and `usage`. Reports,
citations, usage counts, task IDs, and tool results are illustrative scaffolding;
they do not verify research claims or live provider behavior. Granada validates
options before HTTP and has no cassette. Petra's PDF and Lalibela's receipt
are also hand-authored fixtures.

Replay uses a fixed project ID and a scoped placeholder authorization header,
requires no Google credentials or `googleauth`, and restores the provider header
method afterward. Shared setup lives in `support/research.rb`, delegates
transport defaults to `support/runtime.rb`, and keeps configuration on isolated
contexts. `support/models.rb` holds the hosted agent ID. No inference model
registry entry or additional application router is needed. The existing Rake
glob discovers all thirteen tests.

To replace fixtures with live results, add `googleauth` to your local bundle,
configure Application Default Credentials with Vertex hosted-research access,
and run a script with `LIVE=1 GOOGLE_CLOUD_PROJECT=your-project`. The cassette
player scrubs bearer tokens. A live agent can choose different tools, sources,
terminal states, or usage; review the scaffolding assertions when replacing
fixtures. Lalibela additionally needs a real saved task receipt in that project.

## Examples (13 of 13 bottled)

01. [Kyoto temple paths](01-kyoto-temple-paths/) — available
02. [Samarkand mosaic watch](02-samarkand-mosaic-watch/) — available
03. [Nairobi railway archive](03-nairobi-railway-archive/) — available
04. [Valparaíso funicular sources](04-valparaiso-funicular-sources/) — available
05. [Petra sandstone survey](05-petra-sandstone-survey/) — available
06. [Sundarbans landing deadline](06-sundarbans-landing-deadline/) — available
07. [Reykjavík heat cancel](07-reykjavik-heat-cancel/) — available
08. [Rapa Nui moai budget](08-rapa-nui-moai-budget/) — available
09. [Istanbul cistern sensors](09-istanbul-cistern-sensors/) — available
10. [Okavango water ledger](10-okavango-water-ledger/) — available
11. [Lalibela roof recovery](11-lalibela-roof-recovery/) — available
12. [Granada Alhambra approval](12-granada-alhambra-approval/) — available
13. [Iguazú trail research desk](13-iguazu-trail-research-desk/) — available

## What each scenario adds

| Slot | Hosted research lesson | Ruby idiom |
| --- | --- | --- |
| 01 | Blocking research, sources, thinking, usage | Module functions and immutable `Data.define` |
| 02 | Submit, bounded refresh, pending message | An owning instance, enumerator, endless reader |
| 03 | Hosted Microsoft Learn MCP | `proc`, interpolated brief, context `research`, `then` |
| 04 | Grouped citations with UTF-8 spans | Scoped refinement and `each_with_object` |
| 05 | Inline PDF and file citation page | Customized Data record and `filter_map` |
| 06 | Deadline retaining the task, then recovery | Stateful collection methods and typed rescue |
| 07 | Provider-confirmed cancellation and message error | Snapshot lambda and immutable audit hashes |
| 08 | Budget-exceeded partial report | Hash destructuring with `case/in` |
| 09 | MCP allowlist plus hosted search | Tool manifest, `filter_map`, fluent wait pipeline |
| 10 | Unknown hosted-agent cost, normalized usage | `zip`/`sum` and numbered block parameters |
| 11 | Recover saved ID without another POST | JSON pattern assignment and lazy citation enumerator |
| 12 | Unsupported approval and provider options | Table-driven validation and keyword forwarding |
| 13 | Two studies, source ledger, recoverable failure | Data records, `&method(:collect)`, find pattern, grouping |

Research only exposes hosted tasks, so chat callbacks, local tool classes,
block-declared local schemas, and provider rotation would obscure its lesson.
The siblings vary the supported entry points and task lifecycles instead.

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the scenario conventions.
