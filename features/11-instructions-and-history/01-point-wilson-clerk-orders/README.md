# Instructions and history · 01 · Point Wilson kelp-ledge standing orders

The evening tide clerk at Point Wilson Light Station posts kelp-ledge
standing orders, then asks whether the foghorn tender Alden must be back
on the float before the falling tide drops through 4.5 ft.

**What it teaches**

- `with_instructions` sets the clerk's system prompt. The first entry in
  `chat.messages` is `:system`.
- On OpenAI's Responses API those orders ride in the `instructions`
  field. The first `input` item is the evening board, a user turn.
- `ask` returns a `RubyLLM::Message`. `finish_reason`, `tokens`, and
  `cost` are read off that message.

**Files**

| File | Role |
| --- | --- |
| [`clerk_orders.rb`](clerk_orders.rb) | Posts the standing orders and asks the evening board |
| [`clerk_orders_test.rb`](clerk_orders_test.rb) | Replays the cassette and checks the system role |
| [`cassettes/clerk_orders.yml`](cassettes/clerk_orders.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/01-point-wilson-clerk-orders/clerk_orders.rb
bundle exec ruby features/11-instructions-and-history/01-point-wilson-clerk-orders/clerk_orders_test.rb
```

Both commands replay the cassette. No API key is required. `rake test`
runs the same test with the rest of the bottled examples.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/01-point-wilson-clerk-orders/clerk_orders.rb
```

`LIVE_PROVIDER=openrouter` records
`nvidia/nemotron-3-super-120b-a12b:free` when the daily cap allows. The
helper strips `Authorization` before the file is written. Do not
hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
