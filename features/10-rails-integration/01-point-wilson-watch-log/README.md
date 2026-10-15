# Rails integration · 01 · Point Wilson watch log

The tide clerk at Point Wilson Light Station keeps the morning watch
on an ActiveRecord log. `WatchLog.create!` opens the row. `ask` writes
the board question and the brief, and `watch_entries.count` is 3.

**What it teaches**

- `acts_as_chat` is the application API. The watch log is an ordinary ActiveRecord class.
- `WatchLog.create!(model:, provider:)` saves the row and a `belongs_to :model` on `RubyLLM::ActiveRecord::Model`.
- `ask` persists the user turn and the assistant brief.
- `watch_entries.count` and `log.model_id` are read off the record after the ask.

**Files**

| File | Role |
| --- | --- |
| [`watch_log.rb`](watch_log.rb) | Boots in-memory SQLite, creates the watch log, and asks the board |
| [`watch_log_test.rb`](watch_log_test.rb) | Replays the cassette and checks the brief, the roles, and the model row |
| [`cassettes/watch_log.yml`](cassettes/watch_log.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/01-point-wilson-watch-log/watch_log.rb
bundle exec ruby features/10-rails-integration/01-point-wilson-watch-log/watch_log_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/01-point-wilson-watch-log/watch_log.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
