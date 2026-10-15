# Text to speech · 06 · Kinney Point context speak

The flood watch at Kinney Point on Marrowstone Island speaks through a
tenant context so the spit desk does not inherit the cheap `tts-1`
default. Park page: <https://www.parks.wa.gov/509/Fort-Flagler>.

**What it teaches**

- `ctx.speak` uses the context's `default_speech_model`.
- The global `default_speech_model` is left as it was (the gem default
  `gpt-4o-mini-tts-2025-12-15`).
- `ctx.speak` returns the same `Speech` shape as `RubyLLM.speak`.

**Files**

| File | Role |
| --- | --- |
| [`kinney_context.rb`](kinney_context.rb) | Speaks the flood hail through a context |
| [`kinney_context_test.rb`](kinney_context_test.rb) | Replays the cassette |
| [`cassettes/kinney_context.yml`](cassettes/kinney_context.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/06-kinney-point-context-speak/kinney_context_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

The context sets `default_speech_model` to `tts-1`. `ctx.speak` is called
without `model:`.
