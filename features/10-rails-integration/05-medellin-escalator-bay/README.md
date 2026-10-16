# Rails integration · 05 · Medellín escalator-bay tool

The escalator clerk in Comuna 13 asks whether bay 7 can take the
comparsa La Candelaria. The landing length is not in the question.
The tool writes `ruby_llm_tool_calls`.

**What it teaches**

- A `RubyLLM::Tool` on a persisted log writes `ruby_llm_tool_calls`.
- `message.tool_calls` returns `RubyLLM::ToolCall` values. The result is a `:tool` message.
- RubyLLM 2.1.1 has no application `acts_as_tool_call` macro. The row class is `RubyLLM::ActiveRecord::ToolCall`.

**Files**

| File | Role |
| --- | --- |
| [`bay_tool.rb`](bay_tool.rb) | Persists the bay log and forces bay_length |
| [`bay_tool_test.rb`](bay_tool_test.rb) | Replays the cassette and checks the tool row |
| [`cassettes/bay_tool.yml`](cassettes/bay_tool.yml) | The tool-call round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/05-medellin-escalator-bay/bay_tool.rb
bundle exec ruby features/10-rails-integration/05-medellin-escalator-bay/bay_tool_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/05-medellin-escalator-bay/bay_tool.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
