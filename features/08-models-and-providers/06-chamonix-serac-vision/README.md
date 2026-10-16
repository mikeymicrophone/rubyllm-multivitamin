# Models and providers · 06 · Chamonix serac vision filter

The serac watch on the Vallée Blanche filters the OpenAI clerks who can
read an aerial of the icefall. Clerks without vision stay in the hut with
the paper route card.

**What it teaches**

- `RubyLLM.models.by_provider(:openai).chat_models` is chainable.
- `select { |model| model.supports?(:vision) }` keeps only vision models.
- The complement on the same provider is non-empty: not every OpenAI chat
  model reads an image.
- `gpt-4.1-mini` is in the vision set.

**Files**

| File | Role |
| --- | --- |
| [`serac_vision.rb`](serac_vision.rb) | Filters OpenAI chat models by `supports?(:vision)` |
| [`serac_vision_test.rb`](serac_vision_test.rb) | Checks the split and the sample |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/06-chamonix-serac-vision/serac_vision.rb
bundle exec ruby features/08-models-and-providers/06-chamonix-serac-vision/serac_vision_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
