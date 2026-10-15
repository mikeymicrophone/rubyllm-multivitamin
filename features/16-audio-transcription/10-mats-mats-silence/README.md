# Audio transcription · 10 · Mats Mats silent tape

The Mats Mats Bay watch, inside Port Ludlow, handed over a reel with the
lid on the horn mike. `RubyLLM.transcribe` still returns a
`Transcription`. `text` is empty. That is not a blocked Gemini call and
not a missing file.

**What it teaches**

- Silent audio is HTTP 200 and an empty `text`.
- `ask` is not involved. The desk must treat blank text as a logged
  silence, not as a failed request.

**Files**

| File | Role |
| --- | --- |
| [`mats_silence.rb`](mats_silence.rb) | Transcribes the silent reel |
| [`mats_silence_test.rb`](mats_silence_test.rb) | Replays the cassette |
| [`mats-mats-silence.mp3`](mats-mats-silence.mp3) | One-second silent fixture |
| [`cassettes/mats_silence.yml`](cassettes/mats_silence.yml) | Live OpenAI recording of `gpt-transcribe` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/10-mats-mats-silence/mats_silence_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/10-mats-mats-silence/mats_silence_test.rb
```

**Model**

Recorded on `gpt-transcribe`.
