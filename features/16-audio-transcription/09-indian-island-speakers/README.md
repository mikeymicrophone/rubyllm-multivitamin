# Audio transcription · 09 · Indian Island known-speaker clips

The ammunition-pier watch at Indian Island files a two-voice tape and
hands the desk short reference clips of Alden and Calder. OpenAI's
diarization model can match those clips.

**What it teaches**

- `speaker_names:` and `speaker_references:` identify known voices.
- References are paths. The clips here are about three seconds, inside
  the two-to-ten-second window the model accepts.
- The request sends `known_speaker_names` and `known_speaker_references`.

**Files**

| File | Role |
| --- | --- |
| [`indian_speakers.rb`](indian_speakers.rb) | Transcribes the pier tape with named references |
| [`indian_speakers_test.rb`](indian_speakers_test.rb) | Replays the cassette |
| [`indian-island-watch.mp3`](indian-island-watch.mp3) | Two-voice fixture |
| [`alden-reference.mp3`](alden-reference.mp3) | Alden's reference clip |
| [`calder-reference.mp3`](calder-reference.mp3) | Calder's reference clip |
| [`cassettes/indian_speakers.yml`](cassettes/indian_speakers.yml) | Live OpenAI recording of `gpt-4o-transcribe-diarize` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/09-indian-island-speakers/indian_speakers_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/09-indian-island-speakers/indian_speakers_test.rb
```

**Model**

Recorded on `gpt-4o-transcribe-diarize`.
