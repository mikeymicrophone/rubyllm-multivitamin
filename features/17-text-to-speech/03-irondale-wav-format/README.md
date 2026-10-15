# Text to speech · 03 · Irondale WAV format

The mill clerk at Irondale, on Port Townsend Bay, files the pile hail as
WAV for the dock recorder, which will not take an MP3.

**What it teaches**

- `format: "wav"` is sent as `"response_format":"wav"`.
- `Speech#format` is `"wav"`. `mime_type` is `"audio/wav"`.
- `save` writes RIFF bytes and returns the path. One HTTP call.

**Files**

| File | Role |
| --- | --- |
| [`irondale_wav.rb`](irondale_wav.rb) | Speaks and saves the pile hail as WAV |
| [`irondale_wav_test.rb`](irondale_wav_test.rb) | Replays the cassette |
| [`cassettes/irondale_wav.yml`](cassettes/irondale_wav.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/03-irondale-wav-format/irondale_wav_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Large WAV bodies are replaced
with a short silent WAV. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai` and `format: "wav"`.
