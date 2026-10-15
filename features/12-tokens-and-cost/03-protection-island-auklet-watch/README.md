# Tokens and cost · 03 · Protection Island auklet-watch totals

The refuge clerk on Protection Island logs the morning rhinoceros auklet
count, then answers whether the skiff Cassin's may land extra counters at
Kanem Point before 09:00. Both questions sit on one chat. `chat.tokens`
sums the attempts.

**What it teaches**

- `chat.tokens` aggregates every provider attempt on that chat.
- With `max_retries` 0 and two successful asks, `chat.tokens.input`
  equals the sum of the two replies' input counts.
- The second ask sends the first turn back, so its input is larger.

**Files**

| File | Role |
| --- | --- |
| [`auklet_watch.rb`](auklet_watch.rb) | Asks the count, then the landing, and returns the sums |
| [`auklet_watch_test.rb`](auklet_watch_test.rb) | Replays the cassette and checks the totals |
| [`cassettes/auklet_watch.yml`](cassettes/auklet_watch.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/03-protection-island-auklet-watch/auklet_watch.rb
bundle exec ruby features/12-tokens-and-cost/03-protection-island-auklet-watch/auklet_watch_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/03-protection-island-auklet-watch/auklet_watch.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
