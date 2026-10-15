# Text to speech · 04 · Chimacum streamed chunks

The creek watch at Chimacum wants the ebb hail on the loudspeaker as the
bytes arrive, then files the complete recording for the bridge log.

**What it teaches**

- A block on `RubyLLM.speak` yields `RubyLLM::SpeechChunk` objects.
- Each chunk has `data`, `format`, `mime_type`, and `to_blob`.
- Joined chunk bytes equal the `Speech` the call returns. Chunks are
  consecutive pieces of one recording, not separate files.

**Files**

| File | Role |
| --- | --- |
| [`chimacum_chunks.rb`](chimacum_chunks.rb) | Streams the ebb hail |
| [`chimacum_chunks_test.rb`](chimacum_chunks_test.rb) | Replays the cassette |
| [`cassettes/chimacum_chunks.yml`](cassettes/chimacum_chunks.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/04-chimacum-streamed-chunks/chimacum_chunks_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. The helper shrinks the audio
body after the stream is stored. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`. The OpenAI speech endpoint
streams binary audio; RubyLLM wraps each piece as a `SpeechChunk`.
