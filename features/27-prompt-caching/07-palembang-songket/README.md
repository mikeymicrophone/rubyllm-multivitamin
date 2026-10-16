# Prompt caching · 07 · Palembang songket

The loom clerk in Palembang asks twice with automatic caching on. Wati
starts at 11:30. The second reply reports `tokens.cache_read`. Zero is
a legal miss.

**What it teaches**

- Read `cache_read` on the follow-up, not only the first ask.
- Zero is a reported miss, not an omitted field, when the provider sends it.
- Keep the standing order at the front on both turns.

**Files**

| File | Role |
| --- | --- |
| [`songket.rb`](songket.rb) | Caches, then asks twice |
| [`songket_test.rb`](songket_test.rb) | Checks Wati, No, and an Integer cache_read |
| [`cassettes/songket.yml`](cassettes/songket.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/07-palembang-songket/songket.rb
bundle exec ruby features/27-prompt-caching/07-palembang-songket/songket_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
