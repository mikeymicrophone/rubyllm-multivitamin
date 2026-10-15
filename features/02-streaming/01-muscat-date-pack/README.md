# Streaming · 01 · Muscat date-pack dictation

The packing clerk at the Muttrah date loft in Muscat dictates the posted
board for the incoming loft. `ask` takes a block, and each `RubyLLM::Chunk`
is one piece of that dictation.

**What it teaches**

- A block on `ask` yields a `RubyLLM::Chunk`. `Chunk` inherits `Message`,
  so the block reads `content`, `thinking`, `model`, and `tokens`.
- The model id is `chunk.model`. On this Responses recording it lands on
  the usage chunk and on the returned message: `gpt-4.1-mini`.
- Reasoning, when the model streams it, arrives as chunks whose `content`
  is an empty string and whose `thinking.text` is the delta. An empty
  string is truthy in Ruby, so `if chunk.content` does not skip those
  chunks. `gpt-4.1-mini` often has no thinking chunks.
- Joining every `content` reproduces `message.content`. Joining every
  `thinking.text` reproduces `message.thinking.text`.
- Token counts stay nil until the trailing usage chunk. That chunk repeats
  `finish_reason`, and its counts match `message.tokens`.
- Match a packed weight with `[[:space:]]`, not `\s`. The original
  OpenRouter recording put U+202F between the numeral and `kg`; this
  OpenAI cassette may use a normal space.
- VCR stores a non-ASCII SSE body as YAML `!binary`. `YAML.load_file`
  returns the `data:` lines. An ASCII body keeps `data:` in the raw file.

**Files**

| File | Role |
| --- | --- |
| [`date_dictation.rb`](date_dictation.rb) | Dictates the board and keeps a note for every chunk |
| [`date_dictation_test.rb`](date_dictation_test.rb) | Replays the cassette and checks the chunks against the message |
| [`cassettes/date_dictation.yml`](cassettes/date_dictation.yml) | The streamed Responses SSE body |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation.rb
bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled scenarios.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
