# Streaming · 08 · Fez tannery pit halt

The pit caller at Chouara Tannery in Fez reads a lime round: six Baumé,
five, by the mark five, then four. The master cancels after two spoken
pieces. The rest of the round stays in the cassette and off the log.

**What it teaches**

- `chat.cancel` sets a flag. It does not raise. The next chunk checkpoint
  raises `RubyLLM::CancelledError` with the message `Chat generation cancelled`.
- `CancelledError` inherits `StandardError`. It does not inherit
  `RubyLLM::Error`, so a rescue of `RubyLLM::Error` will not catch it.
- The assistant message is not appended. `chat.messages` still ends on the
  user turn. The pieces the block already kept are the partial call.
- The cassette still holds the full SSE body, including the readings the
  master did not log. Replay stops at the same piece.

**Files**

| File | Role |
| --- | --- |
| [`tannery_halt.rb`](tannery_halt.rb) | Streams the round and cancels after two spoken pieces |
| [`tannery_halt_test.rb`](tannery_halt_test.rb) | Replays the cassette and checks the partial call |
| [`cassettes/tannery_halt.yml`](cassettes/tannery_halt.yml) | The full SSE body, stopped early on replay |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/08-fez-tannery-halt/tannery_halt.rb
bundle exec ruby features/02-streaming/08-fez-tannery-halt/tannery_halt_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/08-fez-tannery-halt/tannery_halt_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
