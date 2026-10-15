# Audio transcription · 12 · Thorndyke watch brief

The float at Thorndyke Bay, on Hood Canal, records Alden's kelp-ledge
clearance. The clerk transcribes the tape, then `chat.ask` writes the
posted brief from `tape.text`. The chat never sees the MP3.

**What it teaches**

- A transcript is ordinary text for the next `ask`.
- The cassette has two interactions: `/v1/audio/transcriptions`, then a
  chat turn that contains the spoken kelp-ledge line.
- Roles on the chat are `system`, `user`, `assistant`.

**Files**

| File | Role |
| --- | --- |
| [`thorndyke_brief.rb`](thorndyke_brief.rb) | Transcribes, then briefs from the text |
| [`thorndyke_brief_test.rb`](thorndyke_brief_test.rb) | Replays the cassette |
| [`thorndyke-kelp.mp3`](thorndyke-kelp.mp3) | Short spoken fixture |
| [`cassettes/thorndyke_brief.yml`](cassettes/thorndyke_brief.yml) | Live OpenAI recording of `gpt-transcribe` then `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/12-thorndyke-watch-brief/thorndyke_brief_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/12-thorndyke-watch-brief/thorndyke_brief_test.rb
```

**Model**

Transcription on `gpt-transcribe`. The brief on `gpt-4.1-mini`.
