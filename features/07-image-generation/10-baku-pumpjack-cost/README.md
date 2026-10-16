# Image generation · 10 · Baku pumpjack cost

The field clerk at Balakhani files a plate of the pumpjack with the walking
beam on the noon stroke, then records token counts on the work order.

**What it teaches**

- `image.tokens.input` and `image.tokens.output` come from `usage` on the
  images response.
- `image.cost.total` is `nil` when the bundled registry has no image price
  for `gpt-image-1-mini` and the response omits `usage.cost`. That is not
  the same as a free chat model's `cost` of `0`.
- The cassette response contains `input_tokens` and `output_tokens`.

**Files**

| File | Role |
| --- | --- |
| [`pumpjack_cost.rb`](pumpjack_cost.rb) | Paints the pumpjack and reads tokens / cost |
| [`pumpjack_cost_test.rb`](pumpjack_cost_test.rb) | Replays the cassette |
| [`cassettes/pumpjack_cost.yml`](cassettes/pumpjack_cost.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/10-baku-pumpjack-cost/pumpjack_cost_test.rb
```

**Model**

`gpt-image-1-mini`. Registry pricing for this id is empty in RubyLLM 2.1.1.
