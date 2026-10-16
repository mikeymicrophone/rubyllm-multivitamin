# Prompt caching · 01 · Luxor alabaster policy

The mill clerk in Luxor keeps a long alabaster standing order at the
front of the chat and turns automatic caching on. Nour starts at 07:15.
A cache hit is not guaranteed; OpenAI sends no `prompt_cache_options`
unless `ttl:`, `key:`, or `mode:` is set.

**What it teaches**

- `with_caching` with no arguments enables provider-default caching.
- Keep the standing order at the beginning.
- Read `tokens.cache_read` when you need the hit count. Zero is legal.

**Files**

| File | Role |
| --- | --- |
| [`alabaster_policy.rb`](alabaster_policy.rb) | Caches, then asks twice |
| [`alabaster_policy_test.rb`](alabaster_policy_test.rb) | Checks Nour and No |
| [`cassettes/alabaster_policy.yml`](cassettes/alabaster_policy.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/01-luxor-alabaster-policy/alabaster_policy.rb
bundle exec ruby features/27-prompt-caching/01-luxor-alabaster-policy/alabaster_policy_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
