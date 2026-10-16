# Rails integration · 06 · Harare mbira-key clerk

The mbira clerk in Mbare stores the workshop rule, then appends the
beeswax rule, then asks about the tight njari. Both system rows stay
on the log.

**What it teaches**

- `with_instructions` persists a `:system` row.
- `append: true` adds a second system row instead of replacing the first.
- `messages.where(role: :system)` reads those rows after a reload.

**Files**

| File | Role |
| --- | --- |
| [`key_clerk.rb`](key_clerk.rb) | Persists two system rows and asks about the keys |
| [`key_clerk_test.rb`](key_clerk_test.rb) | Replays the cassette and checks both system texts |
| [`cassettes/key_clerk.yml`](cassettes/key_clerk.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/06-harare-mbira-clerk/key_clerk.rb
bundle exec ruby features/10-rails-integration/06-harare-mbira-clerk/key_clerk_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/06-harare-mbira-clerk/key_clerk.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
