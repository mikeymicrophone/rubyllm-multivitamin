# Structured output

`with_schema` asks for JSON that matches a schema. Define it as a `Schematist::Schema` subclass (`string`, `integer`, `number`, `array`, `object`, `required: false`, `enum:`) or pass a JSON Schema hash. `response.content` is the JSON text. `response.parsed` is the Hash or Array. The default schema name on the wire is `response`; a manual schema can set `name:`. `with_schema(nil)` returns the chat to prose. `RubyLLM.models.find(id).supports?(:structured_output)` is the registry check. An assumed model is treated as supporting it, so the scenario is responsible for picking a slug that actually lists `structured_outputs`.

OpenRouter's encoder removes a nested `strict` key from the schema object before the request. Optional properties are why strict mode is off on other providers.

Official reference: [Structured output](https://rubyllm.com/structured-output/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free` lists `structured_outputs`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `dots-studio/dots-3-note-preview:free`. Gemma's free models list `response_format` and do not list `structured_outputs`; do not use them for `with_schema` until a cassette shows they honor the schema. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Point Wilson tide board as times and heights — planned
02. Lens cabinet drawer contents — planned
03. Foghorn blast pattern — planned
04. Retort cook card — planned
05. Friday Harbor berth slip — planned
06. Pilot boarding checklist — planned
07. Buoy service ticket — planned
08. Weather round observations — planned
09. Dry dock gate state — planned
10. Ferry slip wind report — planned
11. Net loft work order — planned
12. Chart correction notice — planned
13. Watch handover with boats, tides, and the lens crew — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | A flat Schematist schema and `response.parsed` |
| 02 | An array of objects (one per drawer) |
| 03 | An enum for the blast pattern |
| 04 | Nested object: cook, vessel, temperatures |
| 05 | A manual JSON Schema hash with `additionalProperties: false` |
| 06 | A custom schema `name:` for the checklist |
| 07 | Optional fields (`required: false`) and which keys came back |
| 08 | Numbers that must stay numbers, not strings |
| 09 | `with_schema`, a prose turn with `with_schema(nil)`, then a second schema |
| 10 | The parsed Hash uses string keys |
| 11 | A schema the model fills from a messy handwritten ticket |
| 12 | Reject a parsed result that dropped a required station field |
| 13 | Capstone: nested handover, then a follow-up still under the schema |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
