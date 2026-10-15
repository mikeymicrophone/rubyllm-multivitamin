# Streaming · 01 · Muscat date-pack dictation

The packing clerk at the Muttrah date loft in Muscat dictates the posted
board for the incoming loft. `ask` takes a block, and each `RubyLLM::Chunk`
is one piece of that dictation.

**What it teaches**

- A block on `ask` yields a `RubyLLM::Chunk`. `Chunk` inherits `Message`,
  so the block reads `content`, `thinking`, `model`, and `tokens`.
- The model id on each chunk is `chunk.model`. On this free slug it is
  `nvidia/nemotron-3-super-120b-a12b:free`.
- Reasoning comes through as chunks whose `content` is an empty string and
  whose `thinking.text` is the delta. An empty string is truthy in Ruby, so
  `if chunk.content` does not skip those chunks.
- Joining every `content` reproduces `message.content`. Joining every
  `thinking.text` reproduces `message.thinking.text`.
- Token counts stay nil until the trailing usage chunk. That chunk repeats
  `finish_reason`, and its counts match `message.tokens`.
- The dictated weights use U+202F between the numeral and `kg`. The joined
  speech contains `0.4\u202fkg`. A regexp `\s` does not match that character.
  `[[:space:]]` does. In this cassette the narrow space is the end of one
  delta and `kg` starts the next, so the contiguous weight is the join.
- VCR stores that SSE body as YAML `!binary`. `YAML.load_file` returns the
  `data:` lines. A raw read of the file does not contain them.

**Files**

| File | Role |
| --- | --- |
| [`date_dictation.rb`](date_dictation.rb) | Dictates the board and keeps a note for every chunk |
| [`date_dictation_test.rb`](date_dictation_test.rb) | Replays the cassette and checks the chunks against the message |
| [`cassettes/date_dictation.yml`](cassettes/date_dictation.yml) | The streamed Chat Completions response |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation.rb
bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled scenarios.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/01-muscat-date-pack/date_dictation_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
