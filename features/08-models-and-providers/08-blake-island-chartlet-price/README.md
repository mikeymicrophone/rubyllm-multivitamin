# Models and providers · 08 · Blake Island chartlet price

The park boat off Blake Island looks up the paint clerk who can draw a
chartlet of the Tillicum Village landing. `price(:input)` is the posted
rate, not a guess from the brochure. An unknown rate column is an error.

**What it teaches**

- `RubyLLM.models.image_models` lists paint clerks. `gemini-2.5-flash-image`
  prefers first-party `gemini`.
- `price(:input)` is USD per million tokens: `0.3` on that model, `30` for
  `price(:output)`.
- For every image model in the bundled registry, `price(:input)` is `nil`
  or a Numeric. It does not raise.
- `price(:banana)` raises `ArgumentError` naming the valid kinds.

**Files**

| File | Role |
| --- | --- |
| [`chartlet_price.rb`](chartlet_price.rb) | Reads image prices and an unknown kind |
| [`chartlet_price_test.rb`](chartlet_price_test.rb) | Checks nil-or-number and the ArgumentError |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/08-blake-island-chartlet-price/chartlet_price.rb
bundle exec ruby features/08-models-and-providers/08-blake-island-chartlet-price/chartlet_price_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider. The registry entry is
`gemini-2.5-flash-image` on Gemini.
