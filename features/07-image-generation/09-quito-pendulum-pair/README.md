# Image generation · 09 · Quito pendulum pair

The clerk at Ciudad Mitad del Mundo wants two plates of the Foucault
pendulum from one request: one for the noon round, one for the relief's
kit.

**What it teaches**

- `count: 2` sends `"n":2` and `RubyLLM.paint` returns an Array of Image.
- A default `count` of 1 returns a single Image, not a one-element array.
- Usage lives on the first image. `tokens.output` on the second is `nil`.

**Files**

| File | Role |
| --- | --- |
| [`pendulum_pair.rb`](pendulum_pair.rb) | Paints two plates in one call |
| [`pendulum_pair_test.rb`](pendulum_pair_test.rb) | Replays the cassette |
| [`cassettes/pendulum_pair.yml`](cassettes/pendulum_pair.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/07-image-generation/09-quito-pendulum-pair/pendulum_pair_test.rb
```

**Model**

`gpt-image-1-mini`, `count: 2`, `quality: "low"`.
