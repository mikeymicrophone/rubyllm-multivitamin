# Structured output · 01 · Point Wilson tide heights

The tide clerk at Point Wilson copies the morning board into a flat schema: clocks, heights, and the times Alden and Retort can move. `response.content` stays JSON text. `response.parsed` is the Hash.

**What it teaches**

- `with_schema` takes a `Schematist::Schema` subclass. RubyLLM 2.1.1 does not define `RubyLLM::Schema`. `RubyLLM::Models::Schema` validates the model registry.
- `response.content` is the JSON string. `response.parsed` is the Hash, and `JSON.parse(content)` equals it.
- Parsed keys are strings. `low_height_ft` is a Float, `0.4`, not a string.
- A Schematist `title` becomes `text.format.name`. This one is `posted_tide_board`, with `strict` true. The dialect URL `$schema` is not on the wire.

**Files**

| File | Role |
| --- | --- |
| [`tide_heights.rb`](tide_heights.rb) | Asks for the posted board |
| [`tide_heights_test.rb`](tide_heights_test.rb) | Replays the cassette |
| [`cassettes/tide_heights.yml`](cassettes/tide_heights.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/04-structured-output/01-point-wilson-tide-heights/tide_heights_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/01-point-wilson-tide-heights/tide_heights_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026 and lists `structured_output`.
