# Prompt caching · 02 · Dubrovnik wall stone

The wall clerk in Dubrovnik asks for a one-hour cache write, then thirty
minutes. `gpt-4.1-mini` rejects `1h` as an invalid value (only `30m` is
listed) and then rejects `30m` because `prompt_cache_options` is not
supported on this model.

**What it teaches**

- `with_caching(ttl: "1h")` and `ttl: "30m"` are request-level lifetimes.
- The advertised value and the model support check are two different 400s.
- Two chats, two TTLs, one cassette.

**Files**

| File | Role |
| --- | --- |
| [`wall_stone.rb`](wall_stone.rb) | Asks once per TTL |
| [`wall_stone_test.rb`](wall_stone_test.rb) | Checks both ttl strings and both 400s |
| [`cassettes/wall_stone.yml`](cassettes/wall_stone.yml) | Two Responses 400s |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/02-dubrovnik-wall-stone/wall_stone.rb
bundle exec ruby features/27-prompt-caching/02-dubrovnik-wall-stone/wall_stone_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
