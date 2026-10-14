# Structured output · 03 · Cape Disappointment blast pattern

The foghorn card at Cape Disappointment is both a schema enum and a Decisions choice. `with_schema` fills `three-second blast` and `92` psi. `RubyLLM::Judge` asks `gpt-6-luna` which pattern is posted, and the answer is the symbol `:three_second_blast` with a probability for each option.

**What it teaches**

- `string` `enum:` limits the pattern the schema will accept.
- A judgment is not `with_schema`. `PatternCall` posts to `https://api.openai.com/v1/decisions` with `model` `gpt-6-luna`.
- The question goes out as `type: choice`. Each option `value` is the declared name (`three_second_blast`), and the words are the `description`.
- The request body has `model`, `input`, and `questions`. It has no `text.format`.

**Files**

| File | Role |
| --- | --- |
| [`blast_pattern.rb`](blast_pattern.rb) | Schema on `gpt-4.1-mini`, then the choice on `gpt-6-luna` |
| [`blast_pattern_test.rb`](blast_pattern_test.rb) | Replays the cassette |
| [`cassettes/blast_pattern.yml`](cassettes/blast_pattern.yml) | Live OpenAI recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/03-cape-disappointment-blast-pattern/blast_pattern_test.rb
```

Re-record. The judgment always uses `OPENAI_API_KEY` and `gpt-6-luna`, even when `LIVE_PROVIDER=openrouter` retargets the schema call:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/03-cape-disappointment-blast-pattern/blast_pattern_test.rb
```

Do not hand-author the cassette.

**Model**

The schema turn is `gpt-4.1-mini`. The decision is `gpt-6-luna` on `POST /v1/decisions`.
