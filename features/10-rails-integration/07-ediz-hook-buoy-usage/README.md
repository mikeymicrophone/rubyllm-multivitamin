# Rails integration · 07 · Ediz Hook buoy usage

The buoy tender clerk at Ediz Hook files the service card for bell
buoy 2. The ask writes one `ruby_llm_usages` row whose token
columns match the reply.

**What it teaches**

- `ask` writes a `ruby_llm_usages` row on the persisted log.
- The row's `input_tokens` match `response.tokens.input` and `chat.tokens.input`.
- `status` is `succeeded` for a finished attempt.

**Files**

| File | Role |
| --- | --- |
| [`buoy_usage.rb`](buoy_usage.rb) | Asks on the buoy log and reads the usage row |
| [`buoy_usage_test.rb`](buoy_usage_test.rb) | Replays the cassette and checks the token columns |
| [`cassettes/buoy_usage.yml`](cassettes/buoy_usage.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/07-ediz-hook-buoy-usage/buoy_usage.rb
bundle exec ruby features/10-rails-integration/07-ediz-hook-buoy-usage/buoy_usage_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/07-ediz-hook-buoy-usage/buoy_usage.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
