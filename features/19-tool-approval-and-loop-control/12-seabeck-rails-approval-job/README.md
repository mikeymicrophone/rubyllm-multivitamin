# Tool approval and loop control · 12 · Seabeck Rails approval job

The harbor master at Seabeck marina parks the gate for the seiner Elwha.
The decision lives on `ruby_llm_tool_calls.approval`. A later `find` on
the agent class restores the tools and throws the latch.

**What it teaches**

- `ask_later` then `complete` on an `acts_as_chat` log parks when the
  tool `requires_approval`. The tool-call row has no approval yet.
- `approve` writes `"approved"` on `RubyLLM::ActiveRecord::ToolCall`.
- `HarborMaster.find` reapplies the tools. `complete` executes from the
  saved decision, the way a job would after the web process recorded it.

**Files**

| File | Role |
| --- | --- |
| [`gate_latch.rb`](gate_latch.rb) | Parks the gate on a persisted log, then finds and approves |
| [`gate_latch_test.rb`](gate_latch_test.rb) | Replays the cassette |
| [`cassettes/gate_latch.yml`](cassettes/gate_latch.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/12-seabeck-rails-approval-job/gate_latch_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/12-seabeck-rails-approval-job/gate_latch_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
