# Audio transcription · 03 · Sekiu Spanish hail

The Sekiu float hails Neah Bay in Spanish so the Makah pilot boat hears
that the tug Alden is asking for a práctico. `language: "es"` is the ISO
639-1 hint on the request.

**What it teaches**

- `language:` sends the spoken-language hint in the provider's code.
- The cassette multipart body includes `language` and `es`.
- `whisper-1` keeps Spanish station names and the práctico request.

**Files**

| File | Role |
| --- | --- |
| [`sekiu_hail.rb`](sekiu_hail.rb) | Transcribes the Spanish hail |
| [`sekiu_hail_test.rb`](sekiu_hail_test.rb) | Replays the cassette |
| [`sekiu-hail.mp3`](sekiu-hail.mp3) | Short Spanish fixture |
| [`cassettes/sekiu_hail.yml`](cassettes/sekiu_hail.yml) | Live OpenAI recording of `whisper-1` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/03-sekiu-spanish-hail/sekiu_hail_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/03-sekiu-spanish-hail/sekiu_hail_test.rb
```

**Model**

Recorded on `whisper-1` with `language: "es"`.
