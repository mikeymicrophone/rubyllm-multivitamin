# Structured output · 08 · Smith Island weather round

The Smith Island clipboard is a schema of numbers, then a Decisions score for whether the skiff can leave. Pressure is `30.12`, wind is `8` knots, air is `48` F. The score sits on the calm end of the scale.

**What it teaches**

- `number` and `integer` parse as numbers. They are not strings of digits.
- `RubyLLM::Judge` `score` posts `type: score` to `/v1/decisions` on `gpt-6-luna`.
- Level labels on the wire are the indexes `"0"`, `"1"`, and `"2"`. The words ride along as descriptions.
- `judgment.sea_state.score` can fall between indexes. This calm round is under `0.5`, and level `0` holds most of the probability.

**Files**

| File | Role |
| --- | --- |
| [`weather_round.rb`](weather_round.rb) | Schema on `gpt-4.1-mini`, then the score on `gpt-6-luna` |
| [`weather_round_test.rb`](weather_round_test.rb) | Replays the cassette |
| [`cassettes/weather_round.yml`](cassettes/weather_round.yml) | Live OpenAI recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/08-smith-island-weather-round/weather_round_test.rb
```

Re-record. The score always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/08-smith-island-weather-round/weather_round_test.rb
```

**Model**

The clipboard is `gpt-4.1-mini`. The sea-state score is `gpt-6-luna`.
