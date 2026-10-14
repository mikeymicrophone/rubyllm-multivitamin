# Tools

A tool is a subclass of `RubyLLM::Tool` with a `description` and an `execute` method. RubyLLM derives a JSON schema from keyword parameters when you do not declare one; declare `parameter` or `parameters` when the model needs types and descriptions. The class name becomes the tool name in snake_case, with a trailing `Tool` dropped. A class nested in a module keeps that module in the name, and `::` is written as `--` (the horn-relief cassette records `cape_disappointment_relief--posted_horn_card`). Override `self.tool_name` to keep a short domain name. These scenarios do that.

`chat.with_tools(TideBoard)` adds a tool. RubyLLM 2.1.1 has no `with_tool`. `with_tools(nil)` clears the set. One `ask` runs the loop: the model requests a call, RubyLLM runs `execute`, the result goes back as a `:tool` message, and `ask` returns when the model stops calling tools. A String result is that message's content. A Hash or Array is sent as JSON. Return `{ error: "..." }` for a miss the model can recover from. Raise for a failure the application owns; the exception leaves `ask` and no `:tool` message is appended.

`with_tool_options(choice:)` takes `:auto`, `:none`, `:required`, a tool name, or a tool class. `calls: :many` sends `parallel_tool_calls`. Callbacks are `before_tool_call`, `after_tool_result`, and `after_tool_progress`. The 1.x names `on_tool_call` and `on_tool_result` are gone. `halt` and `RubyLLM::Tool::Halt` are gone; stop the loop with `generate` and `run_tools`.

A streamed tool call yields argument strings on the chunks. `before_tool_call` receives a Hash. The Cape Disappointment horn relief already recorded that split.

The model-facing name, the arguments, and the result all use the scenario's words.

Official reference: [Tools](https://rubyllm.com/tools/) and [tool parameters](https://rubyllm.com/tool-parameters/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free` advertises `tools` and `tool_choice`. Fallback: `liquid/lfm-2.5-2.6b:free`. Do not use `nvidia/nemotron-3.5-content-safety:free` here; it does not advertise tools. Checked 14 October 2026.

## Examples (0 of 13 bottled, 13 scripted)

Every script, test, and README below is written. None of the cassettes are recorded. OpenRouter's free-model daily limit was exhausted on 14 October 2026 and resets at 2026-10-15 00:00 UTC. Each chat test skips with `cassette pending live recording` until a live run writes the cassette. Do not hand-author one. A bottled count below includes only a scenario whose cassette is a live recording.

01. [Point Wilson tide window](01-point-wilson-tide-window/) — script ready; cassette not recorded
02. [New Dungeness lens drawer](02-new-dungeness-lens-drawer/) — script ready; cassette not recorded
03. [Cape Disappointment compressor](03-cape-disappointment-compressor/) — script ready; cassette not recorded
04. [Anacortes retort cook book](04-anacortes-retort-cook-book/) — script ready; cassette not recorded
05. [Friday Harbor berth desk](05-friday-harbor-berth-desk/) — script ready; cassette not recorded
06. [Neah Bay pilot window](06-neah-bay-pilot-window/) — script ready; cassette not recorded
07. [Ediz Hook buoy battery](07-ediz-hook-buoy-battery/) — script ready; cassette not recorded
08. [Smith Island barometer](08-smith-island-barometer/) — script ready; cassette not recorded
09. [Bremerton dry dock sill](09-bremerton-dry-dock-sill/) — script ready; cassette not recorded
10. [Port Townsend slip wind](10-port-townsend-slip-wind/) — script ready; cassette not recorded
11. [Port Angeles net loft](11-port-angeles-net-loft/) — script ready; cassette not recorded
12. [Juan de Fuca chart stream](12-juan-de-fuca-chart-stream/) — script ready; cassette not recorded
13. [Admiralty Inlet watch desk](13-admiralty-inlet-watch-desk/) — script ready; cassette not recorded

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One tool, no parameters, `execute` returns the posted board as a String |
| 02 | A required keyword (`drawer:`) inferred from `execute`; a bad `call` returns `{ error: }` |
| 03 | An explicit `parameter` with a description, `required: true`, and a numeric type |
| 04 | A tool instance that closes over today's cook book, and an integer parameter |
| 05 | `with_tools` adds a second tool; `choice: :required` lets the model pick |
| 06 | `with_tools(nil)` replaces the set. There is no `with_tool` |
| 07 | A miss returns `{ error: }` as JSON, and the model calls the tool again |
| 08 | A raise inside `execute` leaves `ask` and does not append a `:tool` message |
| 09 | The model must pass a station name that is not in the question's first sentence |
| 10 | Two calls in one turn via `calls: :many`; a Hash return is JSON on the tool message |
| 11 | `with_tool_options(choice:)` forces the twine tool, then the choice is cleared |
| 12 | Streamed argument strings, `before_tool_call` / `after_tool_result` / `after_tool_progress`, and `chat.messages` |
| 13 | Capstone: three tools, a second ask uses the result, then `generate` + `run_tools` stops without `halt` |

## Cassettes still to record

- `01-point-wilson-tide-window/cassettes/posted_board.yml`
- `02-new-dungeness-lens-drawer/cassettes/lens_drawer.yml`
- `03-cape-disappointment-compressor/cassettes/compressor_card.yml`
- `04-anacortes-retort-cook-book/cassettes/cook_card.yml`
- `05-friday-harbor-berth-desk/cassettes/berth_desk.yml`
- `06-neah-bay-pilot-window/cassettes/pilot_window.yml`
- `07-ediz-hook-buoy-battery/cassettes/buoy_battery.yml`
- `08-smith-island-barometer/cassettes/barometer_glass.yml`
- `09-bremerton-dry-dock-sill/cassettes/sill_depth.yml`
- `10-port-townsend-slip-wind/cassettes/slip_wind.yml`
- `11-port-angeles-net-loft/cassettes/twine_stock.yml`
- `12-juan-de-fuca-chart-stream/cassettes/chart_stream.yml`
- `13-admiralty-inlet-watch-desk/cassettes/watch_desk.yml`

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
