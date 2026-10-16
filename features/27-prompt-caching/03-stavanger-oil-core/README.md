# Prompt caching · 03 · Stavanger oil core

The core clerk in Stavanger marks the standing order as an explicit
breakpoint. `gpt-4.1-mini` answers HTTP 400:
`prompt_cache_breakpoint is not supported on this model`. The mark is
still on the wire.

**What it teaches**

- `cache_until_here` marks the latest message.
- Combined with empty `with_caching` (no `mode:`).
- The request body has `prompt_cache_breakpoint`. This cheap slug rejects it.

**Files**

| File | Role |
| --- | --- |
| [`oil_core.rb`](oil_core.rb) | Marks, then asks |
| [`oil_core_test.rb`](oil_core_test.rb) | Checks the breakpoint and the 400 |
| [`cassettes/oil_core.yml`](cassettes/oil_core.yml) | One Responses 400 |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/03-stavanger-oil-core/oil_core.rb
bundle exec ruby features/27-prompt-caching/03-stavanger-oil-core/oil_core_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
