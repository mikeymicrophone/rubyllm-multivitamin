# Rails integration · 13 · Admiralty Inlet watch desk

The watch desk at Point Wilson on Admiralty Inlet keeps the tide
tool, the model row, the usage ledger, and a follow-up on one
persisted log.

**What it teaches**

- One `acts_as_chat` record holds the transcript, the tool call, the model association, and usage rows.
- A second `ask` on the same record sends the earlier tool result back.
- `RubyLLM::ActiveRecord::Model` and `ToolCall` stay the gem's records.

**Files**

| File | Role |
| --- | --- |
| [`watch_desk.rb`](watch_desk.rb) | Asks the board, then asks the relief follow-up |
| [`watch_desk_test.rb`](watch_desk_test.rb) | Replays the cassette and checks the tool, the model, and the follow-up |
| [`cassettes/watch_desk.yml`](cassettes/watch_desk.yml) | The two Chat Completions rounds, including the tool |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/13-admiralty-inlet-watch-desk/watch_desk.rb
bundle exec ruby features/10-rails-integration/13-admiralty-inlet-watch-desk/watch_desk_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/13-admiralty-inlet-watch-desk/watch_desk.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
