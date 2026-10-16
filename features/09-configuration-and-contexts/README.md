# Configuration and contexts

`RubyLLM.configure` sets the global `Configuration`. OpenRouter's keys are `openrouter_api_key`, `openrouter_api_base`, `openrouter_app_url` (sent as `HTTP-Referer`), and `openrouter_app_name` (sent as `X-OpenRouter-Title`). Defaults live on `default_model`, `default_embedding_model`, `default_image_model`, and the other `default_*` readers. Connection knobs include `request_timeout`, `max_retries`, `retry_interval`, `http_proxy`, and `model_registry_file`. An unconfigured provider raises `RubyLLM::ConfigurationError` when you use it.

`RubyLLM.context` dups that configuration and yields the copy. `ctx.chat`, `ctx.embed`, and `ctx.paint` use the copy. The global config is left as it was. Contexts with the same connection settings share a Faraday connection.

Per-chat overrides (`with_temperature`, `with_provider_options`, `with_headers`, `with_context`) live on `Chat`, not on `Configuration`. `with_provider_options` is the 2.1.1 name for extra request fields; `Chat` does not respond to `with_params`.

Official reference: [Configuration](https://rubyllm.com/configuration/), [connection, logging, and contexts](https://rubyllm.com/configuration-connection/), and [advanced request control](https://rubyllm.com/chat-request-control/).

## Models

Chat examples try the free OpenRouter slug first (`nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free` as the second tenant). OpenRouter attribution (`HTTP-Referer`, `X-OpenRouter-Title`) stays on the wire because the provider is still `:openrouter`. When the `:free` catalog answers `free-models-per-day`, set `CONFIGURATION_OPENROUTER_PAID=1` to record `openai/gpt-4.1-mini` (and `openai/gpt-4.1-nano`) on OpenRouter. A 512-token output cap is set because this workspace's OpenRouter key could not afford the default 65536 `max_tokens` on those paid slugs. The Copán context embed uses the free OpenRouter embedding slug (or `openai/text-embedding-3-small` when paid) and `text-embedding-3-small` on OpenAI for the global call. Fallback: `LIVE_PROVIDER=openai` records native OpenAI `gpt-4.1-mini`.

## Examples (13 of 13 bottled)

01. [Siena Palio attribution headers](01-siena-palio-attribution/) — available
02. [Zomba exam-rubric drawer](02-zomba-exam-drawer/) — available
03. [Sousse olive press and medina stall, two contexts](03-sousse-press-and-stall/) — available
04. [Svalbard seed-vault request timeout](04-svalbard-seed-timeout/) — available
05. [Paramaribo pantry key copy](05-paramaribo-pantry-key/) — available
06. [Kaohsiung wafer-fab logger](06-kaohsiung-fab-logger/) — available
07. [Bilbao gantry retry knobs](07-bilbao-gantry-retries/) — available
08. [Limoges enamel OpenRouter base URL](08-limoges-enamel-base/) — available
09. [Asunción harp sampling and params](09-asuncion-harp-sampling/) — available
10. [Kandy tea loft and factory lab](10-kandy-tea-tenant-models/) — available
11. [Copán stela context embed](11-copan-stela-embed/) — available
12. [Nouakchott clinic spare radio](12-nouakchott-clinic-radio/) — available
13. [Maputo pão and chapas router](13-maputo-pao-chapas-router/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | The cassette request carries `HTTP-Referer` and `X-OpenRouter-Title`; `with_headers` cannot replace them |
| 02 | `default_model` used when `chat` gets no model |
| 03 | Two contexts, two OpenRouter titles, global config unchanged after both |
| 04 | `request_timeout` read back from the context and not from `RubyLLM.config` |
| 05 | Mutating the yielded key does not mutate the global one |
| 06 | A logger IO the test can read, without `RUBYLLM_DEBUG` |
| 07 | `max_retries` is 0 on the cassette context and the default elsewhere |
| 08 | `openrouter_api_base` on the cassette URI; `http_proxy` nil; registry path inside the scenario `tmp/` |
| 09 | `with_temperature` and `with_provider_options` on one chat; the other omits both |
| 10 | Each tenant's `default_model` is a different OpenRouter slug |
| 11 | `ctx.embed` Authorization comes from the context; `RubyLLM.embed` uses the global key |
| 12 | Rescue `ConfigurationError` from the empty context only |
| 13 | Capstone: a router vends a context per tenant; `with_headers` and `with_context` |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
