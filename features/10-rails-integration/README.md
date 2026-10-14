# Rails integration

The application owns `Chat` and `Message`. `acts_as_chat` and `acts_as_message` are the whole public persistence API. RubyLLM owns `ruby_llm_models`, `ruby_llm_tool_calls`, `ruby_llm_usages`, `ruby_llm_batches`, `ruby_llm_mcp_credentials`, and `ruby_llm_provider_files`. There is no application `Model` or `ToolCall` class to generate.

`bin/rails generate ruby_llm:install`, `bin/rails db:migrate`, and `bin/rails ruby_llm:load_models` (or `RubyLLM.models.refresh`) load the registry. `bin/rails generate ruby_llm:chat_ui` adds a Hotwire chat. `Chat.create!(model:, provider:, assume_model_exists: true)` then `ask` persists the transcript. Do not validate message content as present: streaming and tool calls save an assistant row before text exists. `with:` persists Active Storage attachments. `add_message` appends without a provider call. `acts_as_chat messages:` can point the model at a different association than the one the UI renders.

A bottled scenario keeps its tiny Rails app inside the scenario folder. Add `rails` to the root Gemfile in the commit that bottles the first one.

Official reference: [Rails integration](https://rubyllm.com/rails/) and [persistence with acts_as](https://rubyllm.com/rails-persistence/).

## Free models

`Chat.create!` uses `nvidia/nemotron-3-super-120b-a12b:free` with `provider: :openrouter` and `assume_model_exists: true`. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. acts_as_chat on a watch log — planned
02. acts_as_message and the transcript — planned
03. Active Storage photo of the tide board — planned
04. Turbo stream of a watch brief — planned
05. A tool call persisted on the watch log — planned
06. Instructions saved as system messages — planned
07. Usage rows in ruby_llm_usages — planned
08. A job that asks on the watch log — planned
09. assume_model_exists on Chat.create! — planned
10. Empty assistant content allowed — planned
11. User transcript separate from the model transcript — planned
12. Cancel a persisted generation — planned
13. Watch log with a chat, a message, and a tide tool — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `acts_as_chat`, create, `ask`, `messages.count` |
| 02 | Roles persisted, including the assistant |
| 03 | `with:` a fixture image, blob attached to the user message |
| 04 | The chat_ui generator's stream target, exercised in a request test |
| 05 | Tool call readable from the message, result stored as a tool-role message |
| 06 | `with_instructions` then `messages.where(role: :system)` |
| 07 | `ruby_llm_usages` has a row whose token columns match `response.tokens` |
| 08 | Active Job calls `ask` and the row is filled when the job finishes |
| 09 | A free slug that is not in the registry still saves |
| 10 | A presence validation on content fails the streaming insert; the scenario leaves it off |
| 11 | `acts_as_chat messages: :llm_messages` while the UI reads `messages` |
| 12 | `cancel` sets the chat's cancelled state and raises `CancelledError` |
| 13 | Capstone: log, tool, usage row, and a second ask |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
