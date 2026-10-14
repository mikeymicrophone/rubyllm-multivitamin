# Configuration and contexts

`RubyLLM.configure` sets the global `Configuration`. OpenRouter's keys are `openrouter_api_key`, `openrouter_api_base`, `openrouter_app_url` (sent as `HTTP-Referer`), and `openrouter_app_name` (sent as `X-OpenRouter-Title`). Defaults live on `default_model`, `default_embedding_model`, `default_image_model`, and the other `default_*` readers. Connection knobs include `request_timeout`, `max_retries`, `retry_interval`, `http_proxy`, and `model_registry_file`. An unconfigured provider raises `RubyLLM::ConfigurationError` when you use it.

`RubyLLM.context` dups that configuration and yields the copy. `ctx.chat`, `ctx.embed`, and `ctx.paint` use the copy. The global config is left as it was. Contexts with the same connection settings share a Faraday connection.

Per-chat overrides (`with_temperature`, `with_provider_options`, `with_headers`, `with_context`) live on `Chat`, not on `Configuration`. `with_provider_options` is the 2.1.1 name for extra request fields; `Chat` does not respond to `with_params`.

Official reference: [Configuration](https://rubyllm.com/configuration/), [connection, logging, and contexts](https://rubyllm.com/configuration-connection/), and [advanced request control](https://rubyllm.com/chat-request-control/).

## Models

The `:free` OpenRouter chat slugs answered `Rate limit exceeded: free-models-per-day` while this feature was bottled (14 October 2026, before the 8 PM ET reset). Chat examples therefore record `openai/gpt-4.1-mini` on OpenRouter, still `provider: :openrouter`, so `HTTP-Referer` and `X-OpenRouter-Title` stay on the wire. The second tenant slug is `openai/gpt-4.1-nano`. A 512-token output cap is set because this workspace's OpenRouter key could not afford the default 65536 `max_tokens`. The Juan de Fuca context embed uses `openai/text-embedding-3-small` on OpenRouter and the same id on OpenAI for the global call. Fallback: `LIVE_PROVIDER=openai` records native OpenAI `gpt-4.1-mini`. Checked 14 October 2026.

## Examples (13 of 13 bottled)

01. [Point Wilson attribution headers](01-point-wilson-attribution/) — available
02. [New Dungeness default model](02-new-dungeness-default-model/) — available
03. [Cannery tenant and light station, two contexts](03-cannery-and-station-contexts/) — available
04. [Cape Disappointment request timeout](04-cape-disappointment-timeout/) — available
05. [Friday Harbor key copy](05-friday-harbor-key-copy/) — available
06. [Smith Island logger](06-smith-island-logger/) — available
07. [Neah Bay retry knobs](07-neah-bay-retry-knobs/) — available
08. [Bremerton OpenRouter base URL](08-bremerton-openrouter-base/) — available
09. [Port Townsend sampling and params](09-port-townsend-sampling/) — available
10. [Ediz Hook and Port Angeles default models](10-ediz-hook-tenant-models/) — available
11. [Juan de Fuca context embed](11-juan-de-fuca-context-embed/) — available
12. [Bell buoy empty context](12-bell-buoy-empty-context/) — available
13. [Admiralty Inlet tenant router](13-admiralty-inlet-tenant-router/) — available

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
| 10 | Each tenant's `default_model` is a different free slug |
| 11 | `ctx.embed` Authorization comes from the context; `RubyLLM.embed` uses the global key |
| 12 | Rescue `ConfigurationError` from the empty context only |
| 13 | Capstone: a router vends a context per tenant; `with_headers` and `with_context` |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
