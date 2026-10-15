# Agents

An agent is a `RubyLLM::Agent` subclass that names a chat setup once. The class macros map onto the same calls a script would make on `RubyLLM.chat`: `model` (with `provider:` and `assume_model_exists:`), `instructions`, `tools`, `schema`, `inputs`, `fallbacks`, `context`, and `chat_model`. `Agent.new.ask` runs the conversation. `Agent.chat` returns a plain `RubyLLM::Chat` and does not wrap `rescue_from`.

`inputs` declares runtime keywords that lazy blocks can read. `schema` accepts a class, a Hash, or an inline DSL block. `fallbacks` is `with_fallbacks`. `context` takes a `RubyLLM.context` object or a config block. `chat_model` turns on Rails mode: `create` / `create!` / `find` / `sync_instructions`.

Instance methods delegate the conversation API: `ask`, `ask_later`, `step`, `complete`, `complete?`, `with_model`, `with_tools`, and the rest. `rescue_from` handles exceptions from those operations on the instance. A handoff is a second agent wrapping the same chat (`Specialist.new(chat: clerk.chat)`), or `find` on a persisted record.

Official reference: [Agents](https://rubyllm.com/agents/) and [Agentic Workflows](https://rubyllm.com/agentic-workflows/).

## Models

Most agent chats record on OpenAI `gpt-4.1-mini` after OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` answered `free-models-per-day` on 15 October 2026. The Port Angeles switch then uses `gpt-4o-mini`. Neah Bay records `openai/gpt-4.1-mini` on OpenRouter so the cassette keeps `X-OpenRouter-Title`. Friday Harbor and Bremerton record unlisted-OpenRouter 400s; Friday Harbor hops to OpenAI when `on:` lists `BadRequestError`. `LIVE_PROVIDER=openrouter` records the free slug on scripts that call `Multivitamin::Models.chat`. Fallback free slug: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.

## Examples (13 of 13 bottled)

01. [Point Wilson tide clerk](01-point-wilson-tide-clerk/) — available
02. [New Dungeness lens cabinet](02-new-dungeness-lens-cabinet/) — available
03. [Cape Disappointment blast card](03-cape-disappointment-blast-card/) — available
04. [Anacortes retort inputs](04-anacortes-retort-inputs/) — available
05. [Friday Harbor berth fallbacks](05-friday-harbor-berth-fallbacks/) — available
06. [Neah Bay pilot context](06-neah-bay-pilot-context/) — available
07. [Ediz Hook buoy chat model](07-ediz-hook-buoy-chat-model/) — available
08. [Smith Island weather loop](08-smith-island-weather-loop/) — available
09. [Bremerton sill rescue](09-bremerton-sill-rescue/) — available
10. [Port Townsend slip find](10-port-townsend-slip-find/) — available
11. [Port Angeles net loft switch](11-port-angeles-net-loft-switch/) — available
12. [Juan de Fuca chart handoff](12-juan-de-fuca-chart-handoff/) — available
13. [Admiralty Inlet watch capstone](13-admiralty-inlet-watch-capstone/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `RubyLLM::Agent` subclass, `model` and `instructions` macros, `Agent.new.ask` |
| 02 | `tools` and `tool_options` on the class; `execute` returns the posted drawer |
| 03 | inline `schema do` DSL; `response.parsed` is the Hash |
| 04 | `inputs :retort` and lazy `instructions { }` that read the retort name |
| 05 | `fallbacks` without `on:` keep a 400; `on: [BadRequestError]` reaches OpenAI |
| 06 | `context` block sets OpenRouter title and timeout; global config is unchanged |
| 07 | `chat_model` plus `create!` persists the buoy log |
| 08 | `ask_later`, `step`, `complete?`; a second `step` returns `nil` |
| 09 | `rescue_from` swallows `BadRequestError` on the instance; `Agent.chat` still raises |
| 10 | `create!` then `find`; the second ask uses the saved slip turns |
| 11 | `with_model` mid-run keeps the twine question on the transcript |
| 12 | Two agents, one chat: the chart clerk hands the conversation to the buoy clerk |
| 13 | Capstone: instructions, a tool, a schema, a follow-up, roles, and tokens |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
