# Audio transcription · 13 · Squamish Harbor watch tape capstone

The outgoing watch at Squamish Harbor, inside Hood Canal, files the
overnight tape with the kelp-ledge vocabulary and word times, then asks
the relief clerk to post the card. This slot puts `prompt:`, `timestamps:`,
and `chat.ask` on one cassette.

**What it teaches**

- `prompt:` and `timestamps: [:word, :segment]` travel on the same
  `whisper-1` call.
- `words`, `segments`, and `duration` stay on the `Transcription` after
  the chat turn.
- `chat.ask` writes the posted card from `tape.text`, including 10:46.

**Files**

| File | Role |
| --- | --- |
| [`squamish_capstone.rb`](squamish_capstone.rb) | Times the tape, then posts the card |
| [`squamish_capstone_test.rb`](squamish_capstone_test.rb) | Replays the cassette |
| [`squamish-harbor-watch.mp3`](squamish-harbor-watch.mp3) | Short spoken fixture |
| [`cassettes/squamish_capstone.yml`](cassettes/squamish_capstone.yml) | Live OpenAI recording of `whisper-1` then `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/13-squamish-harbor-capstone/squamish_capstone_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/13-squamish-harbor-capstone/squamish_capstone_test.rb
```

**Model**

Transcription on `whisper-1`. The posted card on `gpt-4.1-mini`.
