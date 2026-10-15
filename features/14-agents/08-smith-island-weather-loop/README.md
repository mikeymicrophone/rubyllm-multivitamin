# Agents · 08 · Smith Island weather loop

The weather clerk at Smith Island Light posts the falling 29.84-inch glass
one move at a time. `ask_later` stages the barometer card. `step` is the
model's turn. `complete?` tells the desk when to stop.

**What it teaches**

- `complete?` is true on a new agent: nothing is staged yet.
- `ask_later` appends the user turn without a provider call and returns the
  wrapped `RubyLLM::Chat`.
- After `ask_later`, `complete?` is false.
- `step` generates once and returns the assistant message.
- A second `step` returns `nil`. That is the same end `complete` waits for.

**Files**

| File | Role |
| --- | --- |
| [`weather_loop.rb`](weather_loop.rb) | Stages the card, steps once, and reads complete? |
| [`weather_loop_test.rb`](weather_loop_test.rb) | Locks the complete? flags, the Chat return, and the glass |
| [`cassettes/weather_loop.yml`](cassettes/weather_loop.yml) | The one generate round-trip |

**Try it**

```sh
bundle exec ruby features/14-agents/08-smith-island-weather-loop/weather_loop.rb
bundle exec ruby features/14-agents/08-smith-island-weather-loop/weather_loop_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI after the free OpenRouter daily cap.
`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free`
when that cap allows. Checked 15 October 2026.
