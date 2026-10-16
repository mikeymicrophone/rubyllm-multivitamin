# Prompt caching · 08 · Cotonou zémidjan fare

The zémidjan clerk in Cotonou keeps the standing order on a persisted
fare log. Koffi starts at 06:40. Rails stores `cache_until_here` and
`cache_ttl` on the system row.

**What it teaches**

- `with_instructions(..., cache_until_here: { ttl: "1h" })` on `acts_as_chat`.
- Reload the log; the ttl is still `"1h"`.
- The request still carries `prompt_cache_breakpoint`.

**Files**

| File | Role |
| --- | --- |
| [`zemidjan_fare.rb`](zemidjan_fare.rb) | Persists, marks, then asks |
| [`zemidjan_fare_test.rb`](zemidjan_fare_test.rb) | Checks Koffi and the stored ttl |
| [`cassettes/zemidjan_fare.yml`](cassettes/zemidjan_fare.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/08-cotonou-zemidjan-fare/zemidjan_fare.rb
bundle exec ruby features/27-prompt-caching/08-cotonou-zemidjan-fare/zemidjan_fare_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
