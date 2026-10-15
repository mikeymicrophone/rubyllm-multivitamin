# Structured output · 08 · La Paz radiosonde clipboard

The El Alto clipboard is a schema of numbers, then a Decisions score for whether the balloon can leave the shed. Altimeter is `30.12`, wind is `8` knots, air is `48` F. The score sits on the calm end of the scale.

**What it teaches**

- `number` and `integer` parse as numbers. They are not strings of digits.
- `RubyLLM::Judge` `score` posts `type: score` to `/v1/decisions` on `gpt-6-luna`.
- Level labels on the wire are the indexes `"0"`, `"1"`, and `"2"`. The words ride along as descriptions.
- `judgment.launch_state.score` can fall between indexes. This calm round is under `0.5`, and level `0` holds most of the probability.

**Files**

| File | Role |
| --- | --- |
| [`balloon_round.rb`](balloon_round.rb) | Schema on `gpt-4.1-mini`, then the score on `gpt-6-luna` |
| [`balloon_round_test.rb`](balloon_round_test.rb) | Replays the cassette |
| [`cassettes/balloon_round.yml`](cassettes/balloon_round.yml) | Live recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/08-la-paz-radiosonde/balloon_round_test.rb
```

Re-record. The score always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/08-la-paz-radiosonde/balloon_round_test.rb
```

**Model**

The clipboard is `gpt-4.1-mini`. The launch-state score is `gpt-6-luna`.
