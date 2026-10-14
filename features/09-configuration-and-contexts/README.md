# Configuration and contexts

`RubyLLM.configure` sets the global `Configuration`. OpenRouter's keys are `openrouter_api_key`, `openrouter_api_base`, `openrouter_app_url` (sent as `HTTP-Referer`), and `openrouter_app_name` (sent as `X-OpenRouter-Title`). Defaults live on `default_model`, `default_embedding_model`, `default_image_model`, and the other `default_*` readers. Connection knobs include `request_timeout`, `max_retries`, `retry_interval`, `http_proxy`, and `model_registry_file`. An unconfigured provider raises `RubyLLM::ConfigurationError` when you use it.

`RubyLLM.context` dups that configuration and yields the copy. `ctx.chat`, `ctx.embed`, and `ctx.paint` use the copy. The global config is left as it was. Contexts with the same connection settings share a Faraday connection.

Official reference: [Configuration](https://rubyllm.com/configuration/) and [connection, logging, and contexts](https://rubyllm.com/configuration-connection/).

## Free models

A context that never calls a provider needs no model and no cassette. A context that chats uses `nvidia/nemotron-3-super-120b-a12b:free`. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. OpenRouter attribution headers for the light station — planned
02. Default model versus an explicit model — planned
03. Cannery tenant and light station, two contexts — planned
04. A longer request timeout on one context only — planned
05. A key change on one context leaves the global key — planned
06. Logger and log level — planned
07. Retry settings on the station context — planned
08. Registry file path kept off the user cache — planned
09. Proxy left unset — planned
10. Per-tenant default models — planned
11. ctx.embed uses the context key, RubyLLM.embed does not — planned
12. A context with no key raises ConfigurationError — planned
13. A small tenant router for the station and the cannery — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | The cassette request carries `HTTP-Referer` and `X-OpenRouter-Title` |
| 02 | `default_model` used when `chat` gets no model |
| 03 | Two contexts, two keys, two cassettes, global config unchanged after both |
| 04 | `request_timeout` read back from the context and not from `RubyLLM.config` |
| 05 | Mutating the yielded config does not mutate the global one |
| 06 | A logger IO the test can read, without `RUBYLLM_DEBUG` |
| 07 | `max_retries` is 0 on the cassette context and the default elsewhere |
| 08 | `model_registry_file` points at a path inside the scenario's `tmp/` |
| 09 | Document the nil proxy; the test asserts `http_proxy` is nil |
| 10 | Each tenant's `default_model` is a different free slug |
| 11 | Embedding call's `Authorization` comes from the context |
| 12 | Rescue `ConfigurationError` from the empty context only |
| 13 | Capstone: a router object that vends a context per tenant and chats once |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
