# Text to speech · 05 · Oak Bay nova vs alloy

The range keeper at Oak Bay files the same bearing hail in `nova` for
the front range and in `alloy` for the rear, so the packets can tell
which light is speaking.

**What it teaches**

- Two `RubyLLM.speak` calls with the same hail and different `voice:` values.
- Each request names the voice that was asked for.
- Both recordings stay on `tts-1`.

**Files**

| File | Role |
| --- | --- |
| [`oak_bay_voices.rb`](oak_bay_voices.rb) | Speaks the bearing hail in nova, then alloy |
| [`oak_bay_voices_test.rb`](oak_bay_voices_test.rb) | Replays the cassette |
| [`cassettes/oak_bay_voices.yml`](cassettes/oak_bay_voices.yml) | Live OpenAI recording of two voices |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/05-oak-bay-nova-vs-alloy/oak_bay_voices_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`. Voices `nova` then `alloy`.
