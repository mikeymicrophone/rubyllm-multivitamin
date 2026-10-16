# Tokens and cost · 10 · Lahore truck-art unpriced clerk

The paint clerk at the Lahore truck-art yard files the Bedford Sohni
Dharti's morning card. Those tokens are then priced on an assumed clerk
who is not in the registry. With the reported OpenRouter zero still on
the Tokens object, `cost_for` returns 0. With only input and output
counts, `cost.total` is `nil`.

**What it teaches**

- `RubyLLM::Model.default` builds the same synthetic clerk `assume_model_exists`
  would, with no `price(:input)`, and does not open a socket.
- `cost_for` still returns `tokens.reported_cost` when that field is
  set, even though the clerk has no registry rates.
- `RubyLLM::Tokens.new(input:, output:)` drops the reported price. That
  same unlisted clerk then yields `nil` rather than pretending the work
  was free.

**Files**

| File | Role |
| --- | --- |
| [`truck_art.rb`](truck_art.rb) | Asks the paint card, then prices the tokens on an unlisted clerk |
| [`truck_art_test.rb`](truck_art_test.rb) | Replays the cassette and checks the nil total |
| [`cassettes/truck_art.yml`](cassettes/truck_art.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/10-lahore-truck-art-clerk/truck_art.rb
bundle exec ruby features/12-tokens-and-cost/10-lahore-truck-art-clerk/truck_art_test.rb
```

Both commands replay the cassette. No API key is required. The unlisted clerk is `RubyLLM::Model.default` and never opens a socket.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/10-lahore-truck-art-clerk/truck_art.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter for the paint
card. The unlisted clerk is local. Fallback if the free slug is gone:
`liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
