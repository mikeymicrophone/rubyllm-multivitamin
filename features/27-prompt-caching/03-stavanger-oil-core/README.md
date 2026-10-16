# Prompt caching · 03 · Stavanger oil core

The core clerk in Stavanger marks the standing order as an explicit
breakpoint with a one-hour lifetime. Sigrid logs at 06:50.

**What it teaches**

- `cache_until_here(ttl: "1h")` marks the latest message.
- Combined with `with_caching(mode: "explicit")`.
- The request body has `prompt_cache_breakpoint`.

**Files**

| File | Role |
| --- | --- |
| [`oil_core.rb`](oil_core.rb) | Marks, then asks |
| [`oil_core_test.rb`](oil_core_test.rb) | Checks the breakpoint and Sigrid |
| [`cassettes/oil_core.yml`](cassettes/oil_core.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/03-stavanger-oil-core/oil_core.rb
bundle exec ruby features/27-prompt-caching/03-stavanger-oil-core/oil_core_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
