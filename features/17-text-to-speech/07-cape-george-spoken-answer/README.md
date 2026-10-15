# Text to speech · 07 · Cape George spoken chat answer

The watch at Cape George, on Discovery Bay, asks the clerk for a
one-sentence inbound hail, then speaks that answer to the packet Alden.

**What it teaches**

- `chat.ask` writes a hail, then `RubyLLM.speak` reads `answer.content`.
- The speech request body is the assistant text, not the question.
- Two HTTP calls share one cassette: chat on `gpt-4.1-mini`, then speech
  on `tts-1`.

**Files**

| File | Role |
| --- | --- |
| [`cape_george_answer.rb`](cape_george_answer.rb) | Asks, then speaks the hail |
| [`cape_george_answer_test.rb`](cape_george_answer_test.rb) | Replays the cassette |
| [`cassettes/cape_george_answer.yml`](cassettes/cape_george_answer.yml) | Live OpenAI chat plus speech |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/07-cape-george-spoken-answer/cape_george_answer_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Chat: `gpt-4.1-mini`. Speech: `tts-1`.
