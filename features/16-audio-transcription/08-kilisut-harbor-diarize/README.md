# Audio transcription · 08 · Kilisut Harbor diarized watch

Two voices share the Kilisut Harbor tape, between Indian Island and
Marrowstone: the weather clerk on the barometer, then the horn tender on
visibility. `gpt-4o-transcribe-diarize` labels each segment.

**What it teaches**

- The diarization model defaults to `diarized_json`.
- `transcription.segments` is an array of hashes with `speaker` and `text`.
- Speaker labels are the provider's names until `speaker_names:` is set.

**Files**

| File | Role |
| --- | --- |
| [`kilisut_diarize.rb`](kilisut_diarize.rb) | Transcribes the two-voice watch tape |
| [`kilisut_diarize_test.rb`](kilisut_diarize_test.rb) | Replays the cassette |
| [`kilisut-harbor-watch.mp3`](kilisut-harbor-watch.mp3) | Two-voice fixture |
| [`cassettes/kilisut_diarize.yml`](cassettes/kilisut_diarize.yml) | Live OpenAI recording of `gpt-4o-transcribe-diarize` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/08-kilisut-harbor-diarize/kilisut_diarize_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/08-kilisut-harbor-diarize/kilisut_diarize_test.rb
```

**Model**

Recorded on `gpt-4o-transcribe-diarize`.
