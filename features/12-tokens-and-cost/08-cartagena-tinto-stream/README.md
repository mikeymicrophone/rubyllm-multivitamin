# Tokens and cost · 08 · Cartagena tinto stream usage

The tinto clerk on the Getsemaní corner in Cartagena dictates the steep
card for the cart La Popa. Usage is requested on the stream. The counts
land on the last chunk, and that last chunk matches the message.

**What it teaches**

- A streamed `ask` sends `stream_options.include_usage`.
- `chunk.tokens` stays nil until the last chunk. An earlier chunk can
  already carry `finish_reason` with nil input tokens.
- The returned message's tokens and `cost.total` match that last chunk.

**Files**

| File | Role |
| --- | --- |
| [`tinto_stream.rb`](tinto_stream.rb) | Streams the steep card and records each chunk's usage |
| [`tinto_stream_test.rb`](tinto_stream_test.rb) | Replays the cassette and checks the last chunk |
| [`cassettes/tinto_stream.yml`](cassettes/tinto_stream.yml) | The streamed Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/08-cartagena-tinto-stream/tinto_stream.rb
bundle exec ruby features/12-tokens-and-cost/08-cartagena-tinto-stream/tinto_stream_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/08-cartagena-tinto-stream/tinto_stream.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
