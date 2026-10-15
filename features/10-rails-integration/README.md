# Rails integration

The application owns `Chat` and `Message`. `acts_as_chat` and `acts_as_message` are the whole public persistence API. RubyLLM owns `ruby_llm_models`, `ruby_llm_tool_calls`, `ruby_llm_usages`, `ruby_llm_batches`, `ruby_llm_mcp_credentials`, and `ruby_llm_provider_files`. There is no application `Model` or `ToolCall` class to generate. In 2.1.1 those rows are `RubyLLM::ActiveRecord::Model` and `RubyLLM::ActiveRecord::ToolCall`. `acts_as_tool_call` and `acts_as_model` are not application macros.

A bottled scenario boots an in-memory SQLite ActiveRecord schema inside the scenario folder. That is enough to exercise `create!`, `ask`, streaming, tools, attachments, and associations. It is not a full Rails application.

`Chat.create!(model:, provider:, assume_model_exists: true)` then `ask` persists the transcript. Do not validate message content as present: streaming and tool calls save an assistant row before text exists. `with:` sends a file on a persisted chat. `add_message` appends without a provider call. `ask_later` then `complete` is the split a job would use. `acts_as_chat messages:` can point the model at a different association than the one the clerk posts.

Official reference: [Rails integration](https://rubyllm.com/rails/) and [persistence with acts_as](https://rubyllm.com/rails-persistence/).

## Free models

The scripts call `Multivitamin::Models.chat(provider: :openai)` and record `gpt-4.1-mini`. The free OpenRouter slug `nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded: free-models-per-day` on 14 October 2026. `LIVE_PROVIDER=openrouter` records that slug when the daily cap allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.

## Examples (13 of 13 bottled)

01. [Point Wilson watch log](01-point-wilson-watch-log/) — available
02. [New Dungeness lens log](02-new-dungeness-lens-log/) — available
03. [Point Wilson tide plate](03-point-wilson-tide-plate/) — available
04. [Cape Disappointment blast stream](04-cape-disappointment-blast-stream/) — available
05. [Friday Harbor berth tool](05-friday-harbor-berth-tool/) — available
06. [Smith Island weather clerk](06-smith-island-weather-clerk/) — available
07. [Ediz Hook buoy usage](07-ediz-hook-buoy-usage/) — available
08. [Port Townsend slip later](08-port-townsend-slip-later/) — available
09. [Neah Bay pilot slug](09-neah-bay-pilot-slug/) — available
10. [Bremerton empty gate](10-bremerton-empty-gate/) — available
11. [Port Angeles net transcripts](11-port-angeles-net-transcripts/) — available
12. [Juan de Fuca cancel log](12-juan-de-fuca-cancel-log/) — available
13. [Admiralty Inlet watch desk](13-admiralty-inlet-watch-desk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `acts_as_chat`, `create!`, `ask`, `messages.count`, `chat.model` |
| 02 | `acts_as_message`, `add_message`, roles after a reload |
| 03 | `with:` a fixture image on a persisted chat |
| 04 | A streamed `ask` fills the empty assistant row created before the first chunk |
| 05 | `ruby_llm_tool_calls` / `RubyLLM::ActiveRecord::ToolCall`, tool-role message |
| 06 | `with_instructions` then `append: true`, system rows on the record |
| 07 | `ruby_llm_usages` token columns match `response.tokens` |
| 08 | `ask_later` persists the user; `complete` fills the assistant |
| 09 | `assume_model_exists` writes `RubyLLM::ActiveRecord::Model` for a slug missing from the registry |
| 10 | Empty assistant content is allowed; a presence validation is not |
| 11 | `acts_as_chat messages: :llm_messages` while the loft tickets stay separate |
| 12 | `cancel` sets the cancelled column, raises `CancelledError`, and destroys the blank assistant |
| 13 | Capstone: log, tool, model row, usage, and a second ask |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
