# Image generation · 10 · Bremerton dry dock gate cost

The dry dock clerk at Bremerton files a plate of the gate with a frigate
on the sill, then records token counts on the work order.

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
| [`gate_cost.rb`](gate_cost.rb) | Paints the gate and reads tokens / cost |
| [`gate_cost_test.rb`](gate_cost_test.rb) | Replays the cassette |
| [`cassettes/gate_cost.yml`](cassettes/gate_cost.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/10-bremerton-dry-dock-gate-cost/gate_cost_test.rb
```

**Model**

`gpt-image-1-mini`. Registry pricing for this id is empty in RubyLLM 2.1.1.
