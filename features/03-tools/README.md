# Tools

A tool is a subclass of `RubyLLM::Tool` with a `description` and an `execute` method. RubyLLM derives a JSON schema from keyword parameters when you do not declare one; declare `parameter` or `parameters` when the model needs types and descriptions. The class name becomes the tool name in snake_case, with a trailing `Tool` dropped. A class nested in a module keeps that module in the name, and `::` is written as `--` (the horn-relief cassette records `cape_disappointment_relief--posted_horn_card`). Override `self.tool_name` to keep a short domain name. These scenarios do that.

`chat.with_tools(PostedLotBoard)` adds a tool. RubyLLM 2.1.1 has no `with_tool`. `with_tools(nil)` clears the set. One `ask` runs the loop: the model requests a call, RubyLLM runs `execute`, the result goes back as a `:tool` message, and `ask` returns when the model stops calling tools. A String result is that message's content. A Hash or Array is sent as JSON. Return `{ error: "..." }` for a miss the model can recover from. Raise for a failure the application owns; the exception leaves `ask` and no `:tool` message is appended.

`with_tool_options(choice:)` takes `:auto`, `:none`, `:required`, a tool name, or a tool class. `calls: :many` sends `parallel_tool_calls`. Callbacks are `before_tool_call`, `after_tool_result`, and `after_tool_progress`. The 1.x names `on_tool_call` and `on_tool_result` are gone. `halt` and `RubyLLM::Tool::Halt` are gone; stop the loop with `generate` and `run_tools`.

A streamed tool call yields argument strings on the chunks. `before_tool_call` receives a Hash. The Cape Disappointment horn relief already recorded that split.

The model-facing name, the arguments, and the result all use the scenario's words.

Official reference: [Tools](https://rubyllm.com/tools/) and [tool parameters](https://rubyllm.com/tool-parameters/).

## Models

These cassettes were recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free-model daily limit was exhausted that day, so the free slug is the re-record alternative: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`. Do not use `nvidia/nemotron-3.5-content-safety:free` here; it does not advertise tools.

`LIVE=1 LIVE_PROVIDER=openai` records OpenAI again. `LIVE=1 LIVE_PROVIDER=openrouter` overwrites a cassette with the free slug. Replay ignores `LIVE_PROVIDER`.

## Examples (13 of 13 bottled)

01. [Addis Ababa coffee-auction chalkboard](01-addis-ababa-auction-board/) — available
02. [Fes tanner vat card](02-fes-tanner-vat/) — available
03. [Olkaria wellhead card](03-olkaria-wellhead/) — available
04. [Porto lodge cask book](04-porto-lodge-cask/) — available
05. [Accra kente loom desk](05-accra-kente-loom/) — available
06. [Tromsø aurora shutter window](06-tromso-aurora-shutter/) — available
07. [Bogotá emerald parcel](07-bogota-emerald-parcel/) — available
08. [Petra tomb hygrometer](08-petra-tomb-hygrometer/) — available
09. [Hallstatt salt-mine face](09-hallstatt-salt-face/) — available
10. [Aalsmeer greenhouse PAR](10-aalsmeer-greenhouse-par/) — available
11. [Melbourne cricket-net stock](11-melbourne-cricket-net/) — available
12. [Garching beam-time notice](12-garching-beam-notice/) — available
13. [Wellington sitting desk](13-wellington-sitting-desk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One tool, no parameters, `execute` returns the posted chalkboard as a String |
| 02 | A required keyword (`vat:`) inferred from `execute`; a bad `call` returns `{ error: }` |
| 03 | An explicit `parameter` with a description, `required: true`, and a numeric type |
| 04 | A tool instance that closes over today's lodge book, and an integer parameter |
| 05 | `with_tools` adds a second tool; `choice: :required` lets the model pick |
| 06 | `with_tools(nil)` replaces the set. There is no `with_tool` |
| 07 | A miss returns `{ error: }` as JSON, and the model calls the tool again |
| 08 | A raise inside `execute` leaves `ask` and does not append a `:tool` message |
| 09 | The model must pass a station name that is not in the question's first sentence |
| 10 | Two calls in one turn via `calls: :many`; a Hash return is JSON on the tool message |
| 11 | `with_tool_options(choice:)` forces the ball tool, then the choice is cleared |
| 12 | Streamed argument strings, `before_tool_call` / `after_tool_result` / `after_tool_progress`, and `chat.messages` |
| 13 | Capstone: three tools, a second ask uses the result, then `generate` + `run_tools` stops without `halt` |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
