# Text to speech · 13 · Beckett Point radio hail capstone

The radio clerk at Beckett Point, on Discovery Bay, writes a one-sentence
card for the packet Alden, speaks it, and files the clip next to the card.

**What it teaches**

- `chat.ask` writes the radio card, then `RubyLLM.speak`, then `save`.
- The saved path holds the spoken answer.
- Roles are `system`, `user`, `assistant`. The speech model is `tts-1`.

**Files**

| File | Role |
| --- | --- |
| [`beckett_radio.rb`](beckett_radio.rb) | Asks, speaks, and saves the card |
| [`beckett_radio_test.rb`](beckett_radio_test.rb) | Replays the cassette |
| [`cassettes/beckett_radio.yml`](cassettes/beckett_radio.yml) | Live OpenAI chat plus speech |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/13-beckett-point-radio-hail/beckett_radio_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Chat: `gpt-4.1-mini`. Speech: `tts-1`.
