# Audio transcription · 11 · Shine Tidal tokens

The bridge tender at Shine Tidal, on Hood Canal, files the opening tape
and records the token counts on the work order. `Transcription#tokens`
reads usage the way a chat message does.

**What it teaches**

- `gpt-transcribe` reports `usage.type` `duration` and `seconds`.
- `transcription.duration` is that second count. `tokens.input`,
  `tokens.output`, and `cost.total` are `nil`.
- That is not a free chat model's `cost` of `0`. The diarization model
  in slots 08 and 09 is the one that reports token counts.

**Files**

| File | Role |
| --- | --- |
| [`shine_tokens.rb`](shine_tokens.rb) | Transcribes the bridge tape and reads usage |
| [`shine_tokens_test.rb`](shine_tokens_test.rb) | Replays the cassette |
| [`shine-tidal-bridge.mp3`](shine-tidal-bridge.mp3) | Short spoken fixture |
| [`cassettes/shine_tokens.yml`](cassettes/shine_tokens.yml) | Live OpenAI recording of `gpt-transcribe` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/11-shine-tidal-tokens/shine_tokens_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/11-shine-tidal-tokens/shine_tokens_test.rb
```

**Model**

Recorded on `gpt-transcribe`.
