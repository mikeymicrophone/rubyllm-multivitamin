# Tokens and cost · 10 · Roche Harbor customs-float unpriced clerk

The customs clerk at the Roche Harbor float files the ketch Spieden's
morning declaration. Those tokens are then priced on an assumed clerk
who is not in the registry. With the reported OpenRouter zero still on
the Tokens object, `cost_for` returns 0. With only input and output
counts, `cost.total` is `nil`.

**What it teaches**

- `assume_model_exists` on an unlisted slug builds a synthetic model
  with no `price(:input)`.
- `cost_for` still returns `tokens.reported_cost` when that field is
  set, even though the clerk has no registry rates.
- `RubyLLM::Tokens.new(input:, output:)` drops the reported price. That
  same unlisted clerk then yields `nil` rather than pretending the work
  was free.

**Files**

| File | Role |
| --- | --- |
| [`customs_float.rb`](customs_float.rb) | Asks the declaration, then prices the tokens on an unlisted clerk |
| [`customs_float_test.rb`](customs_float_test.rb) | Replays the cassette and checks the nil total |
| [`cassettes/customs_float.yml`](cassettes/customs_float.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/10-roche-harbor-customs-float/customs_float.rb
bundle exec ruby features/12-tokens-and-cost/10-roche-harbor-customs-float/customs_float_test.rb
```

Both commands replay the cassette. No API key is required. The unlisted
clerk never opens a socket.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/10-roche-harbor-customs-float/customs_float.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter for the
declaration. The unlisted clerk is local. Fallback if the free slug is
gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
