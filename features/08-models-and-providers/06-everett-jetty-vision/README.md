# Models and providers · 06 · Everett jetty vision filter

The jetty keeper at the Everett waterfront filters the OpenAI clerks who
can read an aerial of the Snohomish River mudflat channel. Clerks without
vision stay on the dock with the paper soundings.

**What it teaches**

- `RubyLLM.models.by_provider(:openai).chat_models` is chainable.
- `select { |model| model.supports?(:vision) }` keeps only vision models.
- The complement on the same provider is non-empty: not every OpenAI chat
  model reads an image.
- `gpt-4.1-mini` is in the vision set.

**Files**

| File | Role |
| --- | --- |
| [`jetty_vision.rb`](jetty_vision.rb) | Filters OpenAI chat models by `supports?(:vision)` |
| [`jetty_vision_test.rb`](jetty_vision_test.rb) | Checks the split and the sample |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/06-everett-jetty-vision/jetty_vision.rb
bundle exec ruby features/08-models-and-providers/06-everett-jetty-vision/jetty_vision_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
