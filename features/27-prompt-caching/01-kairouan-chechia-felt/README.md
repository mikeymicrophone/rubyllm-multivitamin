# Prompt caching · 01 · Kairouan chechia felt

The felt clerk in Kairouan keeps a long chechia standing order at the
front of the chat and turns automatic caching on. Hamza starts at 08:25.
A cache hit is not guaranteed; OpenAI sends no `prompt_cache_options`
unless `ttl:`, `key:`, or `mode:` is set.

**What it teaches**

- `with_caching` with no arguments enables provider-default caching.
- Keep the standing order at the beginning.
- Read `tokens.cache_read` when you need the hit count. Zero is legal.

**Files**

| File | Role |
| --- | --- |
| [`chechia_felt.rb`](chechia_felt.rb) | Caches, then asks twice |
| [`chechia_felt_test.rb`](chechia_felt_test.rb) | Checks Hamza and No |
| [`cassettes/chechia_felt.yml`](cassettes/chechia_felt.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/01-kairouan-chechia-felt/chechia_felt.rb
bundle exec ruby features/27-prompt-caching/01-kairouan-chechia-felt/chechia_felt_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
