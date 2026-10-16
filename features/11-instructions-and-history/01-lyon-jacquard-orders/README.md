# Instructions and history · 01 · Lyon Jacquard standing orders

The floor walker at a Croix-Rousse canut loft posts warp-weight standing
orders, then asks whether weaver Amélie must be back on the bench before
the falling beam drops through 4.5 kg.

**What it teaches**

- `with_instructions` sets the clerk's system prompt. The first entry in
  `chat.messages` is `:system`.
- On OpenAI's Responses API those orders ride in the `instructions`
  field. On OpenRouter Chat Completions they are a `"role":"system"`
  message. The first `input` or `messages` user turn is the evening board.
- `ask` returns a `RubyLLM::Message`. `finish_reason`, `tokens`, and
  `cost` are read off that message.

**Files**

| File | Role |
| --- | --- |
| [`jacquard_orders.rb`](jacquard_orders.rb) | Posts the standing orders and asks the evening board |
| [`jacquard_orders_test.rb`](jacquard_orders_test.rb) | Replays the cassette and checks the system role |
| [`cassettes/jacquard_orders.yml`](cassettes/jacquard_orders.yml) | Live recording of the standing-orders ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/01-lyon-jacquard-orders/jacquard_orders.rb
bundle exec ruby features/11-instructions-and-history/01-lyon-jacquard-orders/jacquard_orders_test.rb
```

Both commands replay the cassette. No API key is required. `rake test`
runs the same test with the rest of the bottled examples.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/01-lyon-jacquard-orders/jacquard_orders.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. The helper strips `Authorization` before the file is written.
Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
