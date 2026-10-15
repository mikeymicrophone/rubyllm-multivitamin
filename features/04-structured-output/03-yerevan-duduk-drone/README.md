# Structured output · 03 · Yerevan duduk drone card

The duduk card at the Komitas chamber in Yerevan is both a schema enum and a Decisions choice. `with_schema` fills `three-second drone` and `92` mm of reed facing. `RubyLLM::Judge` asks `gpt-6-luna` which drone is posted, and the answer is the symbol `:three_second_drone` with a probability for each option.

**What it teaches**

- `string` `enum:` limits the pattern the schema will accept.
- A judgment is not `with_schema`. `PatternCall` posts to `https://api.openai.com/v1/decisions` with `model` `gpt-6-luna`.
- The question goes out as `type: choice`. Each option `value` is the declared name (`three_second_drone`), and the words are the `description`.
- The request body has `model`, `input`, and `questions`. It has no `text.format`.

**Files**

| File | Role |
| --- | --- |
| [`drone_pattern.rb`](drone_pattern.rb) | Schema on `gpt-4.1-mini`, then the choice on `gpt-6-luna` |
| [`drone_pattern_test.rb`](drone_pattern_test.rb) | Replays the cassette |
| [`cassettes/drone_pattern.yml`](cassettes/drone_pattern.yml) | Live recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/03-yerevan-duduk-drone/drone_pattern_test.rb
```

Re-record. The judgment always uses `OPENAI_API_KEY` and `gpt-6-luna`, even when `LIVE_PROVIDER=openrouter` retargets the schema call:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/03-yerevan-duduk-drone/drone_pattern_test.rb
```

Do not hand-author the cassette.

**Model**

The schema turn is `gpt-4.1-mini`. The decision is `gpt-6-luna` on `POST /v1/decisions`.
