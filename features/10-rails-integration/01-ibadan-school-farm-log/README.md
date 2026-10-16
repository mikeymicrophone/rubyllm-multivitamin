# Rails integration · 01 · Ibadan school-farm log

The school-farm clerk at Government College Ibadan keeps the morning
harvest on an ActiveRecord log. `FarmLog.create!` opens the row. `ask`
writes the plot question and the brief, and `plot_entries.count` is 3.

**What it teaches**

- `acts_as_chat` is the application API. The farm log is an ordinary ActiveRecord class.
- `FarmLog.create!(model:, provider:)` saves the row and a `belongs_to :model` on `RubyLLM::ActiveRecord::Model`.
- `ask` persists the user turn and the assistant brief.
- `plot_entries.count` and `log.model_id` are read off the record after the ask.

**Files**

| File | Role |
| --- | --- |
| [`farm_log.rb`](farm_log.rb) | Boots in-memory SQLite, creates the farm log, and asks the harvest board |
| [`farm_log_test.rb`](farm_log_test.rb) | Replays the cassette and checks the brief, the roles, and the model row |
| [`cassettes/farm_log.yml`](cassettes/farm_log.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/01-ibadan-school-farm-log/farm_log.rb
bundle exec ruby features/10-rails-integration/01-ibadan-school-farm-log/farm_log_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/01-ibadan-school-farm-log/farm_log.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
