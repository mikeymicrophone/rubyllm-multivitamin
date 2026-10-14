# Structured output

`with_schema` asks for JSON that matches a schema. Define it as a `Schematist::Schema` subclass (`string`, `integer`, `number`, `boolean`, `array`, `object`, `any_of`, `required: false`, `enum:`) or pass a JSON Schema hash. RubyLLM 2.1.1 does not define `RubyLLM::Schema`. `RubyLLM::Models::Schema` validates registry entries. It is not the chat DSL.

`response.content` is the JSON text. `response.parsed` is the Hash or Array, with string keys. A Schematist `title` becomes the schema name on the wire. A manual hash with no `name` and no `title` is named `response`. A hash may set `name:`. `with_schema(nil)` returns the chat to prose. `RubyLLM.models.find(id, provider: :openai).supports?(:structured_output)` is the registry check.

OpenAI strict mode is on when every property is required. Optional properties (`required: false`) send `strict: false`. Forcing `strict: true` while a property is missing from `required` is HTTP 400. A field that may be null stays required by using `any_of` of `string` and `null`.

OpenRouter's encoder removes a nested `strict` key from the schema object before the request. These cassettes were recorded on OpenAI, so that strip is not in them.

## Luna and the Decisions API

GPT-6 Luna is an OpenAI model, id `gpt-6-luna`. The Decisions API is OpenAI's `POST https://api.openai.com/v1/decisions`, documented at [Decisions](https://developers.openai.com/api/docs/guides/decisions). It returns a probability, a choice, or a score. It does not fill an arbitrary JSON schema. There is no `LUNA_API_KEY`. The call uses `OPENAI_API_KEY`.

RubyLLM 2.1.1 reaches it. `RubyLLM::Providers::OpenAI` selects `Protocols::OpenAI::Decisions` when the operation is `judge`, and that protocol posts to `decisions`. The public call is `RubyLLM::Judge` (or `RubyLLM.judge`). `probability` is sent as `type: predicate`. `choice` and `score` keep those types. Score level labels on the wire are the indexes `"0"`, `"1"`, `"2"`, and the words are descriptions.

The configured default judgment model is `jev-latest` (TypeSafe), not Luna. These scenarios pass `model "gpt-6-luna", provider: :openai`. `gpt-6-luna` lists both `structured_output` and `judgment`. `gpt-4.1-mini` lists `structured_output` and does not list `judgment`. `whisper-1` lists neither. `LIVE_PROVIDER` retargets `Multivitamin::Models.chat` only. A Judge in the same cassette still posts to OpenAI Decisions, so a re-record needs `OPENAI_API_KEY` even when the schema half is pointed at OpenRouter.

`with_schema` on the Responses API and a Judge on Decisions are different calls. Slots 03, 08, 11, and 13 record both.

Official references: [Structured output](https://rubyllm.com/structured-output/) and [Judgments](https://rubyllm.com/judgments/).

## Models

Schema turns were recorded on `gpt-4.1-mini` with `provider: :openai`. Decisions turns were recorded on `gpt-6-luna`. Both ids were on OpenAI's models list, and in RubyLLM's bundled registry, on 14 October 2026.

`LIVE=1 LIVE_PROVIDER=openai` records the schema turns on OpenAI again. `LIVE=1 LIVE_PROVIDER=openrouter` overwrites a schema turn with `nvidia/nemotron-3-super-120b-a12b:free` (`structured_outputs`). Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `dots-studio/dots-3-note-preview:free`. Gemma's free models list `response_format` and do not list `structured_outputs`. Do not use them for `with_schema` until a cassette shows they honor the schema. Replay ignores `LIVE_PROVIDER`.

## Examples (13 of 13 bottled)

01. [Point Wilson tide heights](01-point-wilson-tide-heights/) — available
02. [New Dungeness lens drawers](02-new-dungeness-lens-drawers/) — available
03. [Cape Disappointment blast pattern](03-cape-disappointment-blast-pattern/) — available
04. [Anacortes retort card](04-anacortes-retort-card/) — available
05. [Friday Harbor berth slip](05-friday-harbor-berth-slip/) — available
06. [Neah Bay pilot checklist](06-neah-bay-pilot-checklist/) — available
07. [Ediz Hook buoy ticket](07-ediz-hook-buoy-ticket/) — available
08. [Smith Island weather round](08-smith-island-weather-round/) — available
09. [Bremerton dry dock gate](09-bremerton-dry-dock-gate/) — available
10. [Port Townsend slip wind](10-port-townsend-slip-wind/) — available
11. [Port Angeles net ticket](11-port-angeles-net-ticket/) — available
12. [Juan de Fuca chart reject](12-juan-de-fuca-chart-reject/) — available
13. [Admiralty Inlet watch handover](13-admiralty-inlet-watch-handover/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | A flat Schematist schema, `response.parsed` as a Hash, string keys, and a title used as the schema name |
| 02 | An array of objects, one per lens drawer |
| 03 | An enum, then a Decisions `choice` on `gpt-6-luna` |
| 04 | Nested objects for the cook, the vessel, and the temperatures |
| 05 | A manual JSON Schema hash, `additionalProperties: false`, default name `response` |
| 06 | A custom schema `name:` on that hash |
| 07 | Optional fields (`required: false`), `strict: false`, and which keys came back |
| 08 | Numbers that stay numbers, then a Decisions `score` |
| 09 | `with_schema`, a prose turn with `with_schema(nil)`, then a second schema |
| 10 | Streaming a schema. Joined chunks equal `content`. Parsed keys are strings |
| 11 | Descriptions that steer a messy ticket, then a Decisions predicate |
| 12 | A strict schema OpenAI rejects, a null union that stays strict, and a station check |
| 13 | Capstone: schema plus a tool, a follow-up still under the schema, then one Decisions call with a predicate and a choice |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
