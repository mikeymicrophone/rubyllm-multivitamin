# Audio transcription · 01 · Tatoosh foghorn tape

The foghorn tender at Tatoosh Island, west of Cape Flattery, files the
morning visibility tape. One `RubyLLM.transcribe` call on `gpt-transcribe`
returns a `RubyLLM::Transcription`.

**What it teaches**

- `RubyLLM.transcribe` returns a `RubyLLM::Transcription`.
- `model:` and `provider: :openai` select `gpt-transcribe`.
- `text` and `model` are read off that object.
- The request goes to `https://api.openai.com/v1/audio/transcriptions`.

**Files**

| File | Role |
| --- | --- |
| [`tatoosh_foghorn.rb`](tatoosh_foghorn.rb) | Transcribes the Tatoosh horn tape |
| [`tatoosh_foghorn_test.rb`](tatoosh_foghorn_test.rb) | Replays the cassette |
| [`tatoosh-foghorn.mp3`](tatoosh-foghorn.mp3) | Short spoken fixture |
| [`cassettes/tatoosh_foghorn.yml`](cassettes/tatoosh_foghorn.yml) | Live OpenAI recording of `gpt-transcribe` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/16-audio-transcription/01-tatoosh-foghorn-tape/tatoosh_foghorn_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/01-tatoosh-foghorn-tape/tatoosh_foghorn_test.rb
```

The helper strips `Authorization`. Do not hand-author the cassette.

**Model**

Recorded on `gpt-transcribe` with `provider: :openai`. That is RubyLLM
2.1.1's `default_transcription_model`.
