# Audio transcription · 07 · Mystery Bay streamed deltas

The oyster-float watch at Mystery Bay, on Marrowstone Island, streams the
skiff tape. A block on `RubyLLM.transcribe` yields `TranscriptionChunk`
objects. The call still returns the completed `Transcription`.

**What it teaches**

- `chunk.delta?` is a committed piece to append.
- `chunk.done?` is the final event. Its type includes `done`.
- Joining the delta strings equals `transcription.text`.
- The request sends `stream`.

**Files**

| File | Role |
| --- | --- |
| [`mystery_stream.rb`](mystery_stream.rb) | Streams the skiff tape |
| [`mystery_stream_test.rb`](mystery_stream_test.rb) | Replays the cassette |
| [`mystery-bay-skiff.mp3`](mystery-bay-skiff.mp3) | Short spoken fixture |
| [`cassettes/mystery_stream.yml`](cassettes/mystery_stream.yml) | Live OpenAI recording of `gpt-transcribe` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/07-mystery-bay-stream/mystery_stream_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/07-mystery-bay-stream/mystery_stream_test.rb
```

**Model**

Recorded on `gpt-transcribe`, which streams text deltas. `whisper-1` does
not take a streaming block on this protocol.
