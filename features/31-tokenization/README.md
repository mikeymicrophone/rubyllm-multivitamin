# Tokenization

`RubyLLM.tokenize` returns a `RubyLLM::Tokenization` (`ids`, `count`, `model`, `raw`)
for plain text, excluding chat formatting. `RubyLLM.count_tokens` and
`chat.count_tokens` count a request (history, instructions, function tools, schema,
attachments) without generating. Stage a file with `ask_later` before `count_tokens` if
the attachment is new. These calls do not predict output length or billed usage; read
`response.tokens` after `complete`.

Official reference: [Tokenization](https://rubyllm.com/tokenization/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.tokenize(text, model:, provider:)` and `context.tokenize`
- `tokenization.ids` (frozen, in text order), `count`, `model`, and `raw`
- `RubyLLM.count_tokens(prompt, model:, provider:)` and `context.count_tokens`
- `chat.count_tokens(question)` temporarily includes a user turn without appending it
- `chat.ask_later(question, with: path)` then `chat.count_tokens` for a new attachment
- `RubyLLM::Error` for an unsupported operation

## Providers and fixture provenance

All twelve HTTP cassettes in this feature are **hand-authored**, not live recordings.
Request bodies came from running the actual scripts through the installed RubyLLM 2.1.1
encoder with WebMock blocking network access. Responses follow its provider parsers.
IDs, counts, generated answers, usage, and timestamps are illustrative; they establish
replay and application behavior, not provider accuracy or availability. The Rapa Nui PDF
is hand-authored too. Lalibela raises locally and has no cassette.

| Operation | Provider/model | Key for re-recording |
| --- | --- | --- |
| Plain-text IDs | Cohere `command-r-08-2024` | `COHERE_API_KEY` |
| Plain-text IDs | xAI `grok-4.3` | `XAI_API_KEY` |
| Request count, including schema or a staged PDF | OpenAI `gpt-4.1-mini` (Responses) | `OPENAI_API_KEY` |
| Request count with function tools | Anthropic `claude-sonnet-4-6` | `ANTHROPIC_API_KEY` |
| Plain-text IDs through a model proxy | GPUStack `qwen2.5-7b-instruct` | `GPUSTACK_API_KEY`, `GPUSTACK_API_BASE` |

Tokenize and count are separate capabilities. In the pinned gem, OpenAI has request
counting but no plain-text tokenizer; xAI has a tokenizer but no request-counting
implementation. OpenRouter's Chat Completions protocol has neither operation here.
GPUStack needs a base ending in `/model/proxy/ROUTE_ID/v1`; the tokenizer removes `/v1`
before appending `/tokenize`. Models are pinned in `support/models.rb`; no free-model or
live availability claim is made. `LIVE_PROVIDER` does not retarget these scenarios and
should be unset.

Run any script or its test with no key to replay. Re-record with `LIVE=1` and that
scenario's key; see its README for the command and provenance to update. Feature 12
covers billed `response.tokens`; this feature focuses on the separate pre-generation
endpoints. Provider tools, provider options, and `before_request` hooks are excluded
from counting.

## Examples (13 of 13 bottled)

01. [Kyoto torii inscription](01-kyoto-torii-inscription/) — available
02. [Samarkand Registan label](02-samarkand-registan-label/) — available
03. [Iguazú walkway brief](03-iguazu-walkway-brief/) — available
04. [Petra cistern survey](04-petra-cistern-survey/) — available
05. [Zanzibar dhow manifest](05-zanzibar-dhow-manifest/) — available
06. [Granada Alhambra plaster](06-granada-alhambra-plaster/) — available
07. [Rapa Nui moai survey](07-rapa-nui-moai-survey/) — available
08. [Valparaíso funicular dispatch](08-valparaiso-funicular-dispatch/) — available
09. [Luang Prabang ferry ledger](09-luang-prabang-ferry-ledger/) — available
10. [Isfahan bridge inspection](10-isfahan-bridge-inspection/) — available
11. [Tromsø aurora proxy](11-tromso-aurora-proxy/) — available
12. [Lalibela manuscript refusal](12-lalibela-manuscript-refusal/) — available
13. [Machu Picchu terrace desk](13-machu-picchu-terrace-desk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Cohere IDs and raw response; customized immutable label record and allowance |
| 02 | xAI ordered IDs; `zip`, `filter_map`, numbered blocks, isolated context |
| 03 | Global `count_tokens`; bulletin formatter passed as `&method(:format_notice)` |
| 04 | Owned chat, seeded history, `case/in` record destructuring; counting does not append |
| 05 | Anthropic tool schemas; class and instance tools, `parameters do`, `each_with_object` |
| 06 | Bare versus nested Schematist schema count; fluent `then` pipeline |
| 07 | Local PDF staged with `ask_later`; count leaves generation pending |
| 08 | Scoped String refinement and lazy bulletin; plain-text tokenizer excludes chat instructions |
| 09 | Count then `complete`; callback snapshots, lambda, `zip`/`sum`, reported usage kept separate |
| 10 | Hosted tools, provider options, and a proc request hook are absent from the count |
| 11 | GPUStack backend proxy URL, `assume_model_exists`, adjacent-ID enumerator |
| 12 | Unsupported operations rescued as `RubyLLM::Error`; pattern matching, no HTTP |
| 13 | Explicit admission loop with history, separate output reserve, and stop before staging |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the packaging and idioms checklist.
