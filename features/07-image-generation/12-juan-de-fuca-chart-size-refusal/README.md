# Image generation · 12 · Juan de Fuca chart size refusal

The chart desk asked for a 256-pixel plate of NOAA chart 18465. 
`gpt-image-1-mini` refuses that size with `RubyLLM::BadRequestError`.

**What it teaches**

- `size: "256x256"` raises `RubyLLM::BadRequestError`.
- The message lists the sizes the model accepts: `1024x1024`, `1024x1536`,
  `1536x1024`, and `auto`.
- The cassette is HTTP 400. There is no `b64_json` to shrink.
- `config.max_retries = 0` so Faraday does not double the 400.

**Files**

| File | Role |
| --- | --- |
| [`chart_size_refusal.rb`](chart_size_refusal.rb) | Paints at 256x256 and rescues BadRequestError |
| [`chart_size_refusal_test.rb`](chart_size_refusal_test.rb) | Replays the cassette |
| [`cassettes/chart_size_refusal.yml`](cassettes/chart_size_refusal.yml) | Live OpenAI 400 |

**Try it**

```sh
bundle exec ruby features/07-image-generation/12-juan-de-fuca-chart-size-refusal/chart_size_refusal_test.rb
```

**Model**

`gpt-image-1-mini`. The 256 size is a DALL-E 2 leftover; that model was gone
on 14 October 2026.
