# Rails integration · 05 · Friday Harbor berth tool

The berth clerk at Friday Harbor asks whether berth 7 can take the
seiner Kulshan. The length is not in the question. The tool writes
`ruby_llm_tool_calls`.

**What it teaches**

- A `RubyLLM::Tool` on a persisted log writes `ruby_llm_tool_calls`.
- `message.tool_calls` returns `RubyLLM::ToolCall` values. The result is a `:tool` message.
- RubyLLM 2.1.1 has no application `acts_as_tool_call` macro. The row class is `RubyLLM::ActiveRecord::ToolCall`.

**Files**

| File | Role |
| --- | --- |
| [`berth_tool.rb`](berth_tool.rb) | Persists the berth log and forces berth_length |
| [`berth_tool_test.rb`](berth_tool_test.rb) | Replays the cassette and checks the tool row |
| [`cassettes/berth_tool.yml`](cassettes/berth_tool.yml) | The tool-call round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/05-friday-harbor-berth-tool/berth_tool.rb
bundle exec ruby features/10-rails-integration/05-friday-harbor-berth-tool/berth_tool_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/05-friday-harbor-berth-tool/berth_tool.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
