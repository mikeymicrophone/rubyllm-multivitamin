# Text to speech · 02 · Hadlock slip announcement voice

The slip clerk at Port Hadlock wants the inbound announcement for the
packet Khutzeymateen in `nova`, so the apron can tell it from the alloy
range hail across Oak Bay.

**What it teaches**

- `voice: "nova"` is sent on the `/v1/audio/speech` payload.
- `Speech#voice` is the voice that was requested, not the alloy default.
- `mime_type` stays `"audio/mpeg"` when only the voice changes.

**Files**

| File | Role |
| --- | --- |
| [`slip_voice.rb`](slip_voice.rb) | Speaks the inbound slip hail in nova |
| [`slip_voice_test.rb`](slip_voice_test.rb) | Replays the cassette |
| [`cassettes/slip_voice.yml`](cassettes/slip_voice.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/02-hadlock-slip-announcement-voice/slip_voice_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai` and `voice: "nova"`.
