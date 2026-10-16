# Prompt caching · 12 · Wrocław Nadodrze neon

The neon clerk in Wrocław turns automatic caching on. Marek lights at
19:45. OpenAI reports `cache_read` and omits `cache_write_by_ttl`. That
split is Anthropic.

**What it teaches**

- `tokens.cache_write_by_ttl` is nil when the provider does not split.
- A nil split is not `{}`.
- Read `cache_write` beside the split. `ttl:` is slot 02.

**Files**

| File | Role |
| --- | --- |
| [`nadodrze_neon.rb`](nadodrze_neon.rb) | Asks, then reads the split |
| [`nadodrze_neon_test.rb`](nadodrze_neon_test.rb) | Checks Marek and a nil split |
| [`cassettes/nadodrze_neon.yml`](cassettes/nadodrze_neon.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/12-wroclaw-nadodrze-neon/nadodrze_neon.rb
bundle exec ruby features/27-prompt-caching/12-wroclaw-nadodrze-neon/nadodrze_neon_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
