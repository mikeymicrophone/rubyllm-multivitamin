# Agents · 04 · Anacortes retort inputs

The morning cook at the Anacortes cannery is a different kettle each day.
`inputs :retort` makes that kettle a method inside the agent's lazy
`instructions` block, so the system prompt names Retort No. 2 and Basket 3
without baking those words into the class body.

**What it teaches**

- `inputs :retort` declares a runtime keyword for `new` / `chat`.
- `instructions { }` runs when the agent is built and can read `retort`.
- `model { }` can read inputs too. It cannot read `chat`.
- Passing `retort:` into `CookClerk.new` is how the kettle arrives.

**Files**

| File | Role |
| --- | --- |
| [`retort_inputs.rb`](retort_inputs.rb) | Declares the cook clerk and the Retort input |
| [`retort_inputs_test.rb`](retort_inputs_test.rb) | Checks the rendered instructions and the log line |
| [`cassettes/retort_inputs.yml`](cassettes/retort_inputs.yml) | The cook-card round-trip |

**Try it**

```sh
bundle exec ruby features/14-agents/04-anacortes-retort-inputs/retort_inputs.rb
bundle exec ruby features/14-agents/04-anacortes-retort-inputs/retort_inputs_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. The `model` block picks
`Multivitamin::Models.chat(provider: :openai)` when the basket is Basket 3.
Fallback: OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` via
`LIVE_PROVIDER=openrouter`. Checked 15 October 2026.
