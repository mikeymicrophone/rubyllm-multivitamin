# Image generation · 09 · Smith Island barometer pair

The keeper at Smith Island wants two plates of the barometer glass from one
request: one for the weather round, one for the relief's kit.

**What it teaches**

- `count: 2` sends `"n":2` and `RubyLLM.paint` returns an Array of Image.
- A default `count` of 1 returns a single Image, not a one-element array.
- Usage lives on the first image. `tokens.output` on the second is `nil`.

**Files**

| File | Role |
| --- | --- |
| [`barometer_pair.rb`](barometer_pair.rb) | Paints two plates in one call |
| [`barometer_pair_test.rb`](barometer_pair_test.rb) | Replays the cassette |
| [`cassettes/barometer_pair.yml`](cassettes/barometer_pair.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/09-smith-island-barometer-pair/barometer_pair_test.rb
```

**Model**

`gpt-image-1-mini`, `count: 2`, `quality: "low"`.
