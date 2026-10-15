# Audio transcription · 05 · Morse Creek word timestamps

The sounding skiff off Morse Creek, east of Port Angeles, files a
five-fathom soft-mud tape. `timestamps: [:word, :segment]` on `whisper-1`
asks for both granularities.

**What it teaches**

- `timestamps:` on Chat Completions must be `:word`, `:segment`, or both.
- The request sends `response_format` `verbose_json` and
  `timestamp_granularities`.
- `transcription.words` and `transcription.segments` are arrays of hashes
  with `start` and `end`.
- `duration` is the tape length in seconds.

**Files**

| File | Role |
| --- | --- |
| [`morse_timestamps.rb`](morse_timestamps.rb) | Transcribes the sounding with both granularities |
| [`morse_timestamps_test.rb`](morse_timestamps_test.rb) | Replays the cassette |
| [`morse-creek-sounding.mp3`](morse-creek-sounding.mp3) | Short spoken fixture |
| [`cassettes/morse_timestamps.yml`](cassettes/morse_timestamps.yml) | Live OpenAI recording of `whisper-1` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/05-morse-creek-timestamps/morse_timestamps_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/05-morse-creek-timestamps/morse_timestamps_test.rb
```

**Model**

Recorded on `whisper-1`. Timestamps on this protocol require a
non-streaming `verbose_json` response.
