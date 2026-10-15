# Tokens and cost · 06 · Agate Pass tidal-race cache and thinking

The current clerk at Agate Pass copies the Suquamish race for the ferry
Kitsap. The chat asks for a five-minute prompt cache. This first pass
still reports no cache hits. Reasoning tokens are present.

**What it teaches**

- `tokens.cache_read` and `tokens.cache_write` keep the provider's
  numbers. OpenRouter sent `cached_tokens` 0 and `cache_write_tokens` 0,
  so the buckets are `0`, not `nil`.
- Do not call `to_i` to hide a missing bucket. This recording happens to
  report zero, which is different from omission.
- `tokens.thinking` holds reasoning tokens when the slug reports them.
- `with_caching(ttl: "5m")` asks for a cache. A first pass can still
  report no hits.

**Files**

| File | Role |
| --- | --- |
| [`tidal_race.rb`](tidal_race.rb) | Asks the race card with caching on |
| [`tidal_race_test.rb`](tidal_race_test.rb) | Replays the cassette and checks cache and thinking |
| [`cassettes/tidal_race.yml`](cassettes/tidal_race.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/06-agate-pass-tidal-race/tidal_race.rb
bundle exec ruby features/12-tokens-and-cost/06-agate-pass-tidal-race/tidal_race_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/06-agate-pass-tidal-race/tidal_race.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
