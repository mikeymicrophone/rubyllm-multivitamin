# Tools

A tool is a subclass of `RubyLLM::Tool` with a `description` and an `execute` method. RubyLLM derives a JSON schema from keyword parameters when you do not declare one; declare `parameter` or `parameters` when the model needs types and descriptions. The class name becomes the tool name in snake_case, with a trailing `Tool` dropped. Override `self.tool_name` to keep a domain name.

`chat.with_tools(TideBoard)` adds a tool. `with_tools(nil)` clears the set. One `ask` runs the loop: the model requests a call, RubyLLM runs `execute`, the result goes back as a `:tool` message, and `ask` returns when the model stops calling tools. Return `{ error: "..." }` for a miss the model can recover from. Raise for a failure the application owns.

The model-facing name, the arguments, and the result all use the scenario's words.

Official reference: [Tools](https://rubyllm.com/tools/) and [tool parameters](https://rubyllm.com/tool-parameters/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free` advertises `tools` and `tool_choice`. Fallback: `liquid/lfm-2.5-2.6b:free`. Do not use `nvidia/nemotron-3.5-content-safety:free` here; it does not advertise tools. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Tide window from the posted Point Wilson board — planned
02. Fresnel lens cabinet drawer lookup — planned
03. Foghorn compressor pressure — planned
04. Retort cook schedule — planned
05. Berth availability at Friday Harbor — planned
06. Pilot boarding window — planned
07. Buoy battery voltage — planned
08. Station barometer reading — planned
09. Dry dock sill depth — planned
10. Ferry slip anemometer — planned
11. Net loft twine stock — planned
12. Chart correction lookup — planned
13. The watch desk with several boards to choose from — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One tool, no parameters, `execute` returns the posted board |
| 02 | A required keyword (`drawer:`) inferred from `execute` |
| 03 | An explicit `parameter` with a description and a numeric type |
| 04 | A tool instance that closes over today's cook book |
| 05 | `with_tools` adds a second tool beside the first |
| 06 | `with_tools(nil)` replaces the set |
| 07 | A miss returns `{ error: }` and the model asks a narrower question |
| 08 | A tool that raises, and the test rescues it outside `ask` |
| 09 | The model must pass a station name that is not in the question's first sentence |
| 10 | Two calls in one turn via `with_tool_options(calls: :many)` for two anemometer masts |
| 11 | `with_tool_options(choice:)` forced to the twine tool |
| 12 | Read `tool_calls` and the following `:tool` message off `chat.messages` |
| 13 | Capstone: three tools, the model picks, a second ask uses the result |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
