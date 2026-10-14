# Models and providers

`RubyLLM.models` is the registry: `all`, `chat_models`, `embedding_models`, `by_provider`, `by_family`, and `find`. `supports?(:vision)`, `supports?(:function_calling)`, and `supports?(:structured_output)` answer capability questions. `price(:input)` is USD per million tokens when the registry knows. `find` raises `RubyLLM::ModelNotFoundError` for an unknown id. Resolution is: provider argument, alias table, registry, then `assume_model_exists`. Assuming requires `provider:` and skips the capability check, treating function calling, streaming, vision, and structured output as available.

`refresh` downloads the published catalog and the configured providers' lists. It is a network call. A scenario that refreshes records that HTTP conversation. Listing the bundled registry does not.

Official reference: [Model registry](https://rubyllm.com/models/) and [model resolution](https://rubyllm.com/model-resolution/).

## Free models

Listing the bundled registry needs no key and no cassette file. A live
`refresh` fetches `https://rubyllm.com/models.json` and needs no provider
key. Chat examples in this feature were recorded on OpenAI `gpt-4.1-mini`
(and `gpt-4o-mini` for the mid-chat switch) after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. `LIVE_PROVIDER=openrouter`
records the free slug when the daily cap allows. Fallback:
`liquid/lfm-2.5-2.6b:free`.

## Examples (13 of 13 bottled)

01. [Port Gamble mill float clerk board](01-port-gamble-mill-float/) — available
02. [Deception Pass current-table clerk](02-deception-pass-current-table/) — available
03. [Lime Kiln whale-watch radio alias](03-lime-kiln-whale-watch/) — available
04. [Commencement Bay grain elevator assume exists](04-commencement-bay-grain-elevator/) — available
05. [Hood Canal Bridge opening switch](05-hood-canal-bridge-opening/) — available
06. [Everett jetty vision filter](06-everett-jetty-vision/) — available
07. [Budd Inlet oyster-lease catalogs](07-budd-inlet-oyster-leases/) — available
08. [Blake Island chartlet price](08-blake-island-chartlet-price/) — available
09. [Colvos Passage provider preference](09-colvos-passage-provider/) — available
10. [Alki Point light-list refresh](10-alki-point-light-list/) — available
11. [Skagit Bay missing light](11-skagit-bay-missing-light/) — available
12. [Sucia Island sonnet family](12-sucia-island-sonnet-family/) — available
13. [Marrowstone Point tide-staff capstone](13-marrowstone-point-tide-staff/) — available

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
| 13 | Capstone: capability filter, assume the free slug, one tide-staff question |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
