# Structured output · 04 · Anacortes retort card

The cannery clerk logs the morning cook as three nested objects: the basket, the retort, and the temperatures.

**What it teaches**

- `object` blocks nest `cook`, `vessel`, and `temperatures`.
- Each nested object has its own properties and required list.
- Process minutes and Fahrenheit readings come back as integers.

**Files**

| File | Role |
| --- | --- |
| [`cook_card.rb`](cook_card.rb) | Asks for the cook card |
| [`cook_card_test.rb`](cook_card_test.rb) | Replays the cassette |
| [`cassettes/cook_card.yml`](cassettes/cook_card.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/04-anacortes-retort-card/cook_card_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/04-anacortes-retort-card/cook_card_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
