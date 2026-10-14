# Image generation · 07 · Neah Bay pilot ladder sizes

The pilot station off Neah Bay wants two plates of the boarding ladder on
the grain ship Columbia Range: a square and a landscape.

**What it teaches**

- Two `paint` calls are two `images/generations` interactions.
- `size: "1024x1024"` is square. `size: "1536x1024"` is the landscape size
  this model lists. `256x256` is not on the list.
- Each request body names one size and does not name the other.

**Files**

| File | Role |
| --- | --- |
| [`ladder_sizes.rb`](ladder_sizes.rb) | Paints the ladder twice |
| [`ladder_sizes_test.rb`](ladder_sizes_test.rb) | Replays the cassette |
| [`cassettes/ladder_sizes.yml`](cassettes/ladder_sizes.yml) | Two live OpenAI recordings |

**Try it**

```sh
bundle exec ruby features/07-image-generation/07-neah-bay-pilot-ladder-sizes/ladder_sizes_test.rb
```

**Model**

`gpt-image-1-mini`, `quality: "low"`.
