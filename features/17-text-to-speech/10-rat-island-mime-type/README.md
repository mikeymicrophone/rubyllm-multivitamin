# Text to speech · 10 · Rat Island mime_type

The channel watch between Rat Island and Indian Island files the same
hail as MP3 for the VHF desk and as WAV for the recorder.

**What it teaches**

- `Speech#mime_type` follows `format:`, from RubyLLM's `MIME_TYPES` map.
- The default hail is `"audio/mpeg"`. `format: "wav"` is `"audio/wav"`.
- The MP3 bytes start with an MPEG frame sync. The WAV bytes start with
  `RIFF`.

**Files**

| File | Role |
| --- | --- |
| [`rat_mime.rb`](rat_mime.rb) | Speaks the channel hail as MP3 and WAV |
| [`rat_mime_test.rb`](rat_mime_test.rb) | Replays the cassette |
| [`cassettes/rat_mime.yml`](cassettes/rat_mime.yml) | Live OpenAI recording of two formats |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/10-rat-island-mime-type/rat_mime_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`.
