# Image generation · 08 · Ediz Hook bell buoy models

The buoy tender at Ediz Hook paints the same bell buoy on `gpt-image-1-mini`
and on `gpt-image-2`, then files which id each plate used.

**What it teaches**

- `model:` selects the image model. Both ids are in the bundled registry,
  so `assume_model_exists` stays off.
- Each cassette request names the id that was painted.
- `quality: "low"` stays on both calls.

**Files**

| File | Role |
| --- | --- |
| [`buoy_models.rb`](buoy_models.rb) | Paints the buoy on two models |
| [`buoy_models_test.rb`](buoy_models_test.rb) | Replays the cassette |
| [`cassettes/buoy_models.yml`](cassettes/buoy_models.yml) | Two live OpenAI recordings |

**Try it**

```sh
bundle exec ruby features/07-image-generation/08-ediz-hook-bell-buoy-models/buoy_models_test.rb
```

**Model**

`gpt-image-1-mini` then `gpt-image-2`. Both on OpenAI. `gpt-image-2` is the
library default (`default_image_model`); the catalog still bottles mini
first because it is cheaper.
