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

## Models

These cassettes were recorded on `gpt-4.1-mini` with `provider: :openai`.
Forced `tool_choice` is reliable on that id. Approval is local RubyLLM
state; the cassette records the chat provider only. OpenRouter's free
chat model remains the alternative for a re-record:
`nvidia/nemotron-3-super-120b-a12b:free`, then
`liquid/lfm-2.5-2.6b:free`. Remote MCP approvals additionally need
OpenAI or Azure Responses.

`LIVE=1 LIVE_PROVIDER=openai` records OpenAI again.
`LIVE=1 LIVE_PROVIDER=openrouter` overwrites a cassette with the free
slug. Replay ignores `LIVE_PROVIDER`.

## Examples (13 of 13 bottled)

01. [Port Ludlow publish latch](01-port-ludlow-publish-latch/) — available
02. [Dabob Bay deny the charge](02-dabob-bay-deny-charge/) — available
03. [Quilcene step until complete?](03-quilcene-step-until-complete/) — available
04. [Dosewallips generate then run_tools](04-dosewallips-generate-run-tools/) — available
05. [Duckabush choice: :none then :auto](05-duckabush-choice-none-then-auto/) — available
06. [Hamma Hamma calls: :one](06-hamma-hamma-calls-one/) — available
07. [Lilliwaup concurrency threads](07-lilliwaup-concurrency-threads/) — available
08. [Skokomish pending ask raises](08-skokomish-pending-ask/) — available
09. [Union resolver block](09-union-resolver-block/) — available
10. [Tahuya ten-step budget](10-tahuya-ten-step-budget/) — available
11. [Dewatto progress reports](11-dewatto-progress-reports/) — available
12. [Seabeck Rails approval job](12-seabeck-rails-approval-job/) — available
13. [Bangor horn latch capstone](13-bangor-horn-latch-capstone/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `requires_approval` parks `ask`; `approve` then `complete` posts the notice |
| 02 | `deny` appends `{ error: "The user denied the … tool call." }`; `execute` never runs |
| 03 | `ask_later` then `step until complete? \|\| waiting?`; a further `step` is `nil` |
| 04 | `generate` then `run_tools` stops on the `:tool` card. `halt` is gone |
| 05 | `choice: :none` then `:auto`. The staff stays registered |
| 06 | `calls: :one` sends `parallel_tool_calls` false; the other reach is a later turn |
| 07 | `concurrency: :threads` with `calls: :many`; two `object_id`s |
| 08 | `PendingToolCallsError` inherits `StandardError`, not `RubyLLM::Error` |
| 09 | Resolver block returns `nil` then `true`; `approve` is not the source of truth |
| 10 | A ten-step budget leaves `complete?` false; the next `step` resumes |
| 11 | `progress` plus `before_tool_call` / `after_tool_result` / `after_tool_progress` |
| 12 | Persisted `approval` column; `find` then `complete` from the saved decision |
| 13 | Capstone: mixed tools, a pending `ask` raise, `tool_call:` on execute, a follow-up |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
