# Chat basics · 03 · Chronometer timing card at La Chaux-de-Fonds

The watchmaker at the regulating bench in La Chaux-de-Fonds copies the posted timing card onto the bench slate. A low temperature and a three-line instruction keep the Swiss lever's beat and amplitude from growing a paragraph.

**What it teaches**

- Fluent configuration builds the chat; `Data.define` packages the immutable timing slate.
- `with_temperature(0.0)` sets sampling on this chat before the ask.
- `with_instructions` tells the watchmaker the three lines the slate is allowed to carry.
- The reply is still a `RubyLLM::Message`. Short does not mean missing: `content` holds the card, and `finish_reason` still says why it stopped.

**Files**

| File | Role |
| --- | --- |
| [`timing_card.rb`](timing_card.rb) | Sets a low temperature and asks for the three-line slate |
| [`timing_card_test.rb`](timing_card_test.rb) | Replays the cassette and checks the slate |
| [`cassettes/timing_card.yml`](cassettes/timing_card.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/03-chaux-de-fonds-timing-card/timing_card.rb
bundle exec ruby features/01-chat-basics/03-chaux-de-fonds-timing-card/timing_card_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. The slate is the three lines from the card: 18000 bph, 270 degrees of amplitude, and the Swiss lever. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/03-chaux-de-fonds-timing-card/timing_card.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
