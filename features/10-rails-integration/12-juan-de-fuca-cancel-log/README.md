# Rails integration · 12 · Juan de Fuca cancel log

The chart clerk for the Strait of Juan de Fuca starts a streamed
notice, then cancels after two spoken pieces. The blank assistant
row is destroyed.

**What it teaches**

- `cancel` on a persisted log sets the `cancelled` column and raises `RubyLLM::CancelledError`.
- `CancelledError` inherits `StandardError`, not `RubyLLM::Error`.
- The blank assistant row created for the stream is destroyed. Roles stay `system` and `user`.

**Files**

| File | Role |
| --- | --- |
| [`cancel_log.rb`](cancel_log.rb) | Streams two corrections and cancels the chart log |
| [`cancel_log_test.rb`](cancel_log_test.rb) | Replays the cassette and checks the error and the leftover roles |
| [`cassettes/cancel_log.yml`](cassettes/cancel_log.yml) | The streamed Chat Completions body, which still holds the later deltas |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/12-juan-de-fuca-cancel-log/cancel_log.rb
bundle exec ruby features/10-rails-integration/12-juan-de-fuca-cancel-log/cancel_log_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/12-juan-de-fuca-cancel-log/cancel_log.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
