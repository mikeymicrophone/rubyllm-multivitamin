# Image generation · 12 · Vilnius stamp size refusal

The philatelic desk asked for a 256-pixel plate of the 1922 Gediminas-Tower
issue. `gpt-image-1-mini` refuses that size with `RubyLLM::BadRequestError`.

**What it teaches**

- `size: "256x256"` raises `RubyLLM::BadRequestError`.
- The message lists the sizes the model accepts: `1024x1024`, `1024x1536`,
  `1536x1024`, and `auto`.
- The cassette is HTTP 400. There is no `b64_json` to shrink.
- `config.max_retries = 0` so Faraday does not double the 400.

**Files**

| File | Role |
| --- | --- |
| [`stamp_size_refusal.rb`](stamp_size_refusal.rb) | Paints at 256x256 and rescues BadRequestError |
| [`stamp_size_refusal_test.rb`](stamp_size_refusal_test.rb) | Replays the cassette |
| [`cassettes/stamp_size_refusal.yml`](cassettes/stamp_size_refusal.yml) | Live OpenAI 400 |

**Try it**

```sh
bundle exec ruby features/07-image-generation/12-vilnius-stamp-size-refusal/stamp_size_refusal_test.rb
```

**Model**

`gpt-image-1-mini`. The 256 size is a DALL-E 2 leftover; that model was gone
on 14 October 2026.
