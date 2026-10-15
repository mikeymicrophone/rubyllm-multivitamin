# Image generation · 01 · Jaipur kite-tissue board

The kite loft at Atelier Rohan in Johari Bazaar wants a watercolor of the
posted tissue-color board before the clerk briefs the dyer Farida. One
`RubyLLM.paint` call on `gpt-image-1-mini` returns a `RubyLLM::Image`.

**What it teaches**

- `RubyLLM.paint` returns a `RubyLLM::Image`.
- `model:` and `provider: :openai` select `gpt-image-1-mini`.
- `provider_options: { quality: "low" }` merges onto the images payload.
  The cassette request contains `"quality":"low"` and `"size":"1024x1024"`.
- `mime_type` is `"image/png"`. `base64?` is true on this model.

**Files**

| File | Role |
| --- | --- |
| [`kite_tissue.rb`](kite_tissue.rb) | Paints the posted board |
| [`kite_tissue_test.rb`](kite_tissue_test.rb) | Replays the cassette |
| [`cassettes/kite_tissue.yml`](cassettes/kite_tissue.yml) | Live OpenAI recording of `gpt-image-1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/07-image-generation/01-jaipur-kite-tissue-board/kite_tissue_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/07-image-generation/01-jaipur-kite-tissue-board/kite_tissue_test.rb
```

The helper strips `Authorization` and replaces large `b64_json` payloads
with a 1×1 PNG stand-in. Do not hand-author the cassette.

**Model**

Recorded on `gpt-image-1-mini` with `provider: :openai`, `size: "1024x1024"`,
and `quality: "low"`. Confirmed on `https://api.openai.com/v1/models` on
14 October 2026. `dall-e-2` and `dall-e-3` were gone that day. There is no
`:free` image model; OpenRouter drops `size`, so these cassettes stay on
OpenAI.
