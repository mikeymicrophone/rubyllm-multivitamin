# Image generation · 08 · Almaty Medeu models

The rink clerk at Medeu paints the same high-altitude oval on
`gpt-image-1-mini` and on `gpt-image-2`, then files which id each plate
used.

**What it teaches**

- `model:` selects the image model. Both ids are in the bundled registry,
  so `assume_model_exists` stays off.
- Each cassette request names the id that was painted.
- `quality: "low"` stays on both calls.

**Files**

| File | Role |
| --- | --- |
| [`medeu_models.rb`](medeu_models.rb) | Paints the oval on two models |
| [`medeu_models_test.rb`](medeu_models_test.rb) | Replays the cassette |
| [`cassettes/medeu_models.yml`](cassettes/medeu_models.yml) | Two live OpenAI recordings |

**Try it**

```sh
bundle exec ruby features/07-image-generation/08-almaty-medeu-models/medeu_models_test.rb
```

**Model**

`gpt-image-1-mini` then `gpt-image-2`. Both on OpenAI. `gpt-image-2` is the
library default (`default_image_model`); the catalog still bottles mini
first because it is cheaper.
