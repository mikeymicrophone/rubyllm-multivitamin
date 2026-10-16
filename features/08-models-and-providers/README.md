# Models and providers

`RubyLLM.models` is the registry: `all`, `chat_models`, `embedding_models`, `by_provider`, `by_family`, and `find`. `supports?(:vision)`, `supports?(:function_calling)`, and `supports?(:structured_output)` answer capability questions. `price(:input)` is USD per million tokens when the registry knows. `find` raises `RubyLLM::ModelNotFoundError` for an unknown id. Resolution is: provider argument, alias table, registry, then `assume_model_exists`. Assuming requires `provider:` and skips the capability check, treating function calling, streaming, vision, and structured output as available.

`refresh` downloads the published catalog and the configured providers' lists. It is a network call. A scenario that refreshes records that HTTP conversation. Listing the bundled registry does not.

Official reference: [Model registry](https://rubyllm.com/models/) and [model resolution](https://rubyllm.com/model-resolution/).

## Free models

Listing the bundled registry needs no key and no cassette file. A live
`refresh` fetches `https://rubyllm.com/models.json` and needs no provider
key. Chat examples in this feature were recorded on OpenAI `gpt-4.1-mini`
(and `gpt-4o-mini` for the mid-chat switch) after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered a live probe but
inverted a numeric card. `LIVE_PROVIDER=openrouter` records the free
slug when the daily cap allows. Fallback: `liquid/lfm-2.5-2.6b:free`.

## Examples (13 of 13 bottled)

01. [Valencia Fallas commission board](01-valencia-fallas-board/) — available
02. [Maun flood-gauge clerk](02-maun-flood-gauge/) — available
03. [Mindelo morna alias](03-mindelo-morna-alias/) — available
04. [León sesame lote assume exists](04-leon-sesame-lote/) — available
05. [Zagreb licitar pickup switch](05-zagreb-licitar-pickup/) — available
06. [Chamonix serac vision filter](06-chamonix-serac-vision/) — available
07. [Bobo-Dioulasso shea-kernel catalogs](07-bobo-shea-catalogs/) — available
08. [Meteora icon price](08-meteora-icon-price/) — available
09. [Nairobi ticket-radio preference](09-nairobi-ticket-radio/) — available
10. [AlUla inscription-list refresh](10-alula-inscription-list/) — available
11. [Sialkot missing stitch lot](11-sialkot-missing-lot/) — available
12. [Uppsala Linnaeus family](12-uppsala-linnaeus-family/) — available
13. [Maseru oxygen-run capstone](13-maseru-oxygen-run/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `chat_models` returns entries and does not open a socket |
| 02 | `find` and `supports?(:function_calling)` |
| 03 | The same alias, `provider: :anthropic` and `provider: :bedrock`, different ids |
| 04 | `assume_model_exists: true` without a provider raises `ArgumentError` |
| 05 | `with_model` on the second ask; the cassette shows the new id |
| 06 | `select { |model| model.supports?(:vision) }` |
| 07 | `embedding_models` and `chat_models` do not overlap on id and provider |
| 08 | `price(:input)` is nil or a number, never a raised error, for a known model |
| 09 | A bare id resolves to the preferred first-party provider; `provider:` pins Azure or OpenRouter |
| 10 | `refresh` records the published catalog GET |
| 11 | Rescue `ModelNotFoundError` and do not refresh just to recover |
| 12 | `by_family` narrows a family without a substring scrape of every id |
| 13 | Capstone: capability filter, assume the free slug, one fill-card question |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
