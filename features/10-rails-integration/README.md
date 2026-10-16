# Rails integration

The application owns `Chat` and `Message`. `acts_as_chat` and `acts_as_message` are the whole public persistence API. RubyLLM owns `ruby_llm_models`, `ruby_llm_tool_calls`, `ruby_llm_usages`, `ruby_llm_batches`, `ruby_llm_mcp_credentials`, and `ruby_llm_provider_files`. There is no application `Model` or `ToolCall` class to generate. In 2.1.1 those rows are `RubyLLM::ActiveRecord::Model` and `RubyLLM::ActiveRecord::ToolCall`. `acts_as_tool_call` and `acts_as_model` are not application macros.

A bottled scenario boots an in-memory SQLite ActiveRecord schema inside the scenario folder. That is enough to exercise `create!`, `ask`, streaming, tools, attachments, and associations. It is not a full Rails application.

`Chat.create!(model:, provider:, assume_model_exists: true)` then `ask` persists the transcript. Do not validate message content as present: streaming and tool calls save an assistant row before text exists. `with:` sends a file on a persisted chat. `add_message` appends without a provider call. `ask_later` then `complete` is the split a job would use. `acts_as_chat messages:` can point the model at a different association than the one the clerk posts.

Official reference: [Rails integration](https://rubyllm.com/rails/) and [persistence with acts_as](https://rubyllm.com/rails-persistence/).

## Free models

The scripts call `Multivitamin::Models.chat(provider: :openai)` and record `gpt-4.1-mini`. A live OpenRouter probe of `liquid/lfm-2.5-2.6b:free` on 16 October 2026 returned HTTP 200 with empty content. `LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap allows. Fallback: `liquid/lfm-2.5-2.6b:free`.

## Examples (13 of 13 bottled)

01. [Ibadan school-farm log](01-ibadan-school-farm-log/) — available
02. [Varanasi zari-spool log](02-varanasi-zari-spool-log/) — available
03. [Oaxaca alebrije-firing plate](03-oaxaca-alebrije-plate/) — available
04. [Kumasi fontomfrom stream](04-kumasi-fontomfrom-stream/) — available
05. [Medellín escalator-bay tool](05-medellin-escalator-bay/) — available
06. [Harare mbira-key clerk](06-harare-mbira-clerk/) — available
07. [Dar es Salaam farebox usage](07-dar-es-salaam-farebox-usage/) — available
08. [Mendoza malbec-press later](08-mendoza-malbec-press-later/) — available
09. [Colombo gem-parcel slug](09-colombo-gem-parcel-slug/) — available
10. [Gaborone diamond-tray empty](10-gaborone-diamond-tray/) — available
11. [Lucknow chikan tickets](11-lucknow-chikan-tickets/) — available
12. [Antofagasta flash-furnace cancel](12-antofagasta-furnace-cancel/) — available
13. [Tegucigalpa marimba desk](13-tegucigalpa-marimba-desk/) — available

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
| 11 | `acts_as_chat messages: :llm_messages` while the stitch tickets stay separate |
| 12 | `cancel` sets the cancelled column, raises `CancelledError`, and destroys the blank assistant |
| 13 | Capstone: log, tool, model row, usage, and a second ask |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
