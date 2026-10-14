# Chat basics · 08 · Lighthouse keeper's weather round

The relief keeper at Patos Island Light reads the morning clipboard back into the log. The round is a single ask. The keeper decides it is finished with `stopped?`, not by hunting the word "stop" in the prose.

**What it teaches**

- `ask` returns the round as a `RubyLLM::Message`.
- `stopped?` is true when `finish_reason` is `:stop` and the message did not stop to call a tool.
- The clipboard facts (wind, visibility, barometer, sea) are in `content`. The completion check does not depend on those words.

**Files**

| File | Role |
| --- | --- |
| [`weather_round.rb`](weather_round.rb) | Asks for the round and reads `stopped?` |
| [`weather_round_test.rb`](weather_round_test.rb) | Replays the cassette and checks `stopped?` and the clipboard |
| [`cassettes/weather_round.yml`](cassettes/weather_round.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/08-lighthouse-keepers-weather-round/weather_round.rb
bundle exec ruby features/01-chat-basics/08-lighthouse-keepers-weather-round/weather_round_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The round comes back SE 15 knots, 4 miles, 29.92 inches, and a 2 foot sea, and `stopped?` is true. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/08-lighthouse-keepers-weather-round/weather_round.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
