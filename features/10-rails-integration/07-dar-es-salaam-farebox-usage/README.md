# Rails integration · 07 · Dar es Salaam farebox usage

The farebox clerk at Ubungo files the service card for dala-dala
farebox 2. The ask writes one `ruby_llm_usages` row whose token
columns match the reply.

**What it teaches**

- `ask` writes a `ruby_llm_usages` row on the persisted log.
- The row's `input_tokens` match `response.tokens.input` and `chat.tokens.input`.
- `status` is `succeeded` for a finished attempt.

**Files**

| File | Role |
| --- | --- |
| [`farebox_usage.rb`](farebox_usage.rb) | Asks on the farebox log and reads the usage row |
| [`farebox_usage_test.rb`](farebox_usage_test.rb) | Replays the cassette and checks the token columns |
| [`cassettes/farebox_usage.yml`](cassettes/farebox_usage.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/07-dar-es-salaam-farebox-usage/farebox_usage.rb
bundle exec ruby features/10-rails-integration/07-dar-es-salaam-farebox-usage/farebox_usage_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/07-dar-es-salaam-farebox-usage/farebox_usage.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
