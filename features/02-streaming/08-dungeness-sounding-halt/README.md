# Streaming · 08 · Dungeness sounding halt

The leadsman calls a cast off Dungeness Spit: six fathoms, five, by the
mark five, then four. The mate cancels after two spoken pieces. The rest
of the cast stays in the cassette and off the log.

**What it teaches**

- `chat.cancel` sets a flag. It does not raise. The next chunk checkpoint
  raises `RubyLLM::CancelledError` with the message `Chat generation cancelled`.
- `CancelledError` inherits `StandardError`. It does not inherit
  `RubyLLM::Error`, so a rescue of `RubyLLM::Error` will not catch it.
- The assistant message is not appended. `chat.messages` still ends on the
  user turn. The pieces the block already kept are the partial call.
- The cassette still holds the full SSE body, including the soundings the
  mate did not log. Replay stops at the same piece.

**Files**

| File | Role |
| --- | --- |
| [`sounding_halt.rb`](sounding_halt.rb) | Streams the cast and cancels after two spoken pieces |
| [`sounding_halt_test.rb`](sounding_halt_test.rb) | Replays the cassette and checks the partial call |
| [`cassettes/sounding_halt.yml`](cassettes/sounding_halt.yml) | The full SSE body, stopped early on replay |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/08-dungeness-sounding-halt/sounding_halt.rb
bundle exec ruby features/02-streaming/08-dungeness-sounding-halt/sounding_halt_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/08-dungeness-sounding-halt/sounding_halt_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
