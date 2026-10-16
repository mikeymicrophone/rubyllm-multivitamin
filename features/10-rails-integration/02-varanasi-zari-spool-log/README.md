# Rails integration · 02 · Varanasi zari-spool log

The zari keeper at a Banarasi loom house in Alaipura files the spool
card with `add_message`, then asks which rack holds the 24-strand gold.
Reloading the log from SQLite keeps the same roles.

**What it teaches**

- `acts_as_message` persists roles, including the assistant.
- `add_message` appends the spool card without a provider call.
- A second `ask` adds another user row. Reloading the log keeps the rack.

**Files**

| File | Role |
| --- | --- |
| [`spool_log.rb`](spool_log.rb) | Persists the spool card and asks for rack 3 |
| [`spool_log_test.rb`](spool_log_test.rb) | Replays the cassette and checks roles after a reload |
| [`cassettes/spool_log.yml`](cassettes/spool_log.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/02-varanasi-zari-spool-log/spool_log.rb
bundle exec ruby features/10-rails-integration/02-varanasi-zari-spool-log/spool_log_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/02-varanasi-zari-spool-log/spool_log.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
