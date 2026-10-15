# Audio transcription · 06 · Dungeness Spit SRT card

The chart desk at Dungeness Spit wants the bell-buoy move as a subtitle
card. `format: "srt"` on `whisper-1` puts that card in `transcription.text`.

**What it teaches**

- `format:` uses the provider's own names. OpenAI takes `"srt"` here.
- `text` is the SRT string: cue numbers and `-->` timestamps.
- The request sends `response_format` `srt`.

**Files**

| File | Role |
| --- | --- |
| [`dungeness_srt.rb`](dungeness_srt.rb) | Transcribes the buoy move as SRT |
| [`dungeness_srt_test.rb`](dungeness_srt_test.rb) | Replays the cassette |
| [`dungeness-spit-buoy.mp3`](dungeness-spit-buoy.mp3) | Short spoken fixture |
| [`cassettes/dungeness_srt.yml`](cassettes/dungeness_srt.yml) | Live OpenAI recording of `whisper-1` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/06-dungeness-spit-srt/dungeness_srt_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/06-dungeness-spit-srt/dungeness_srt_test.rb
```

**Model**

Recorded on `whisper-1` with `format: "srt"`.
