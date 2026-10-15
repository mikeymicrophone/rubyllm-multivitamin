# Tool approval and loop control

`requires_approval` on a `RubyLLM::Tool` parks `ask` until `approve` or `deny`. Read `awaiting_approval?`, `pending_approvals`, `waiting?`. `ask_later` stages a user turn. `generate` is one model move. `run_tools` executes pending calls. `step` does whichever is next. `complete` loops until `complete?` or `waiting?`. `choice:` / `calls:` / `concurrency:` live on `with_tool_options`. `PendingToolCallsError` fires if you `ask` while a call is still pending.

Official reference: [Controlling Tool Execution](https://rubyllm.com/tool-execution/) and [Agentic Workflows](https://rubyllm.com/agentic-workflows/).

## RubyLLM 2.1.1 entry points

- `requires_approval` on `RubyLLM::Tool`
- `approve`, `deny`, `pending_approvals`, `awaiting_approval?`
- `ask_later`, `generate`, `run_tools`, `step`, `complete`, `complete?`
- `waiting?`, `awaiting_input?`, `awaiting_tasks?`
- `with_tool_options(choice:, calls:, concurrency:)`
- `RubyLLM::PendingToolCallsError`

## Providers that can record it

Approval is local RubyLLM state; the cassette records the chat provider only. Any tool-capable chat model works. This catalog's default is OpenAI `gpt-4.1-mini` (forced `tool_choice` is reliable). OpenRouter free fallback: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`. Remote MCP approvals additionally need OpenAI or Azure Responses.

## Examples (0 of 13 bottled)

01. Port Ludlow publish latch — planned
02. Dabob Bay deny the charge — planned
03. Quilcene step until complete? — planned
04. Dosewallips generate then run_tools — planned
05. Duckabush choice: :none then :auto — planned
06. Hamma Hamma calls: :one — planned
07. Lilliwaup concurrency threads — planned
08. Skokomish pending ask raises — planned
09. Union resolver block — planned
10. Tahuya ten-step budget — planned
11. Dewatto progress reports — planned
12. Seabeck Rails approval job — planned
13. Bangor horn latch capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
