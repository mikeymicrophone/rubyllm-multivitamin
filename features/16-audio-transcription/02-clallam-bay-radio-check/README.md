# Audio transcription · 02 · Clallam Bay radio check

Calder on the Clallam Bay watch desk files a radio-check tape through a
`RubyLLM.context` aimed at `whisper-1`. `ctx.transcribe` uses that default.
The global config keeps RubyLLM's `gpt-transcribe`.

**What it teaches**

- `ctx.transcribe` accepts the same arguments as `RubyLLM.transcribe`.
- `default_transcription_model` on the context is the model when `model:`
  is omitted.
- `RubyLLM.config.default_transcription_model` stays `gpt-transcribe`.
- A context `request_timeout` of 90 does not change the global 120.

**Files**

| File | Role |
| --- | --- |
| [`clallam_radio.rb`](clallam_radio.rb) | Transcribes the radio check through a context |
| [`clallam_radio_test.rb`](clallam_radio_test.rb) | Replays the cassette |
| [`clallam-bay-radio.mp3`](clallam-bay-radio.mp3) | Short spoken fixture |
| [`cassettes/clallam_radio.yml`](cassettes/clallam_radio.yml) | Live OpenAI recording of `whisper-1` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/02-clallam-bay-radio-check/clallam_radio_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/02-clallam-bay-radio-check/clallam_radio_test.rb
```

**Model**

Recorded on `whisper-1` because that is the context default. The gem default
remains `gpt-transcribe`.
