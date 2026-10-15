# Text to speech · 08 · Kala Point speed instructions

The bluff watch at Kala Point wants the hail spoken slowly, with a calm
delivery, so the packets in Port Townsend Bay can copy it.

**What it teaches**

- `provider_options:` merges OpenAI `instructions` and `speed` onto the
  payload as-is.
- Those keys sit beside `model`, `input`, and `voice`.
- `tts-1` accepts the fields. OpenAI documents `instructions` as a
  `gpt-4o-mini-tts` control; this cassette still carries both keys.

**Files**

| File | Role |
| --- | --- |
| [`kala_speed.rb`](kala_speed.rb) | Speaks the slow hail |
| [`kala_speed_test.rb`](kala_speed_test.rb) | Replays the cassette |
| [`cassettes/kala_speed.yml`](cassettes/kala_speed.yml) | Live OpenAI recording of `tts-1` |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/08-kala-point-speed-instructions/kala_speed_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider_options: { instructions:, speed: 0.85 }`.
