# Image generation · 02 · Mukilteo range light size

The Mukilteo range light sits above the ferry slip on Possession Sound.
The watch asks for a square documentary plate at the smallest size
`gpt-image-1-mini` accepts.

**What it teaches**

- `size:` is present on the OpenAI `images/generations` request.
- Supported sizes on this model are `1024x1024`, `1024x1536`, `1536x1024`,
  and `auto`. `256x256` is not among them.
- The bottled default is `1024x1024`.

**Files**

| File | Role |
| --- | --- |
| [`range_light_size.rb`](range_light_size.rb) | Paints the range light at `1024x1024` |
| [`range_light_size_test.rb`](range_light_size_test.rb) | Replays the cassette and checks `size` |
| [`cassettes/range_light_size.yml`](cassettes/range_light_size.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/02-mukilteo-range-light-size/range_light_size_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/07-image-generation/02-mukilteo-range-light-size/range_light_size_test.rb
```

**Model**

`gpt-image-1-mini`, `size: "1024x1024"`, `quality: "low"`.
