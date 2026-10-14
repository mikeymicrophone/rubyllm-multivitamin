# Models and providers

`RubyLLM.models` is the registry: `all`, `chat_models`, `embedding_models`, `by_provider`, `by_family`, and `find`. `supports?(:vision)`, `supports?(:function_calling)`, and `supports?(:structured_output)` answer capability questions. `price(:input)` is USD per million tokens when the registry knows. `find` raises `RubyLLM::ModelNotFoundError` for an unknown id. Resolution is: provider argument, alias table, registry, then `assume_model_exists`. Assuming requires `provider:` and skips the capability check, treating function calling, streaming, vision, and structured output as available.

`refresh` downloads the published catalog and the configured providers' lists. It is a network call. A scenario that refreshes records that HTTP conversation. Listing the bundled registry does not.

Official reference: [Model registry](https://rubyllm.com/models/) and [model resolution](https://rubyllm.com/model-resolution/).

## Free models

Listing the bundled registry needs no key and no cassette. A live `refresh`, or a chat that uses a free slug, uses OpenRouter. Chat slug: `nvidia/nemotron-3-super-120b-a12b:free`, with `assume_model_exists: true` when `find` cannot see it. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. List chat models and print context windows — planned
02. Find one model and read function calling — planned
03. Resolve one alias on two providers — planned
04. Assume a free OpenRouter slug exists — planned
05. Switch with_model mid-conversation — planned
06. Filter vision models — planned
07. Separate embedding models from chat models — planned
08. Image models and price(:input) — planned
09. Provider preference when an id exists in two places — planned
10. A custom OpenAI-compatible base URL — planned
11. ModelNotFoundError for a slug the registry dropped — planned
12. Filter by family — planned
13. Choose a model by capability, then ask one station question — planned

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
| 09 | A bare id resolves to the preferred first-party provider |
| 10 | `openai_api_base` pointed at a stand-in, cassette on that host |
| 11 | Rescue `ModelNotFoundError` and do not refresh just to recover |
| 12 | `by_family` narrows a family without a substring scrape of every id |
| 13 | Capstone: capability filter, assume the free slug, one tide-board question |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
