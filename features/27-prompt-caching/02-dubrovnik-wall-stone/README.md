# Prompt caching · 02 · Dubrovnik wall stone

The wall clerk in Dubrovnik runs the same Luka board twice: once with a
one-hour cache write, once with five minutes. `prompt_cache_options.ttl`
is on the wire.

**What it teaches**

- `with_caching(ttl: "1h")` and `ttl: "5m"` are request-level lifetimes.
- A longer write can cost more.
- Two chats, two TTLs, one cassette.

**Files**

| File | Role |
| --- | --- |
| [`wall_stone.rb`](wall_stone.rb) | Asks once per TTL |
| [`wall_stone_test.rb`](wall_stone_test.rb) | Checks both ttl strings |
| [`cassettes/wall_stone.yml`](cassettes/wall_stone.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/02-dubrovnik-wall-stone/wall_stone.rb
bundle exec ruby features/27-prompt-caching/02-dubrovnik-wall-stone/wall_stone_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
