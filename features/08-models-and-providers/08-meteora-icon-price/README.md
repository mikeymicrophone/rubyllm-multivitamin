# Models and providers · 08 · Meteora icon price

The monastery stair workshop at Meteora looks up the paint clerk who can
draw the Great Meteoron stair. `price(:input)` is the posted rate, not a
guess from the pilgrim brochure. An unknown rate column is an error.

**What it teaches**

- `RubyLLM.models.image_models` lists paint clerks. `gemini-2.5-flash-image`
  prefers first-party `gemini`.
- `price(:input)` is USD per million tokens: `0.3` on that model, `30` for
  `price(:output)`.
- For every image model in the bundled registry, `price(:input)` is `nil`
  or a Numeric. It does not raise.
- `price(:egg_tempera)` raises `ArgumentError` naming the valid kinds.

**Files**

| File | Role |
| --- | --- |
| [`icon_price.rb`](icon_price.rb) | Reads image prices and an unknown kind |
| [`icon_price_test.rb`](icon_price_test.rb) | Checks nil-or-number and the ArgumentError |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/08-meteora-icon-price/icon_price.rb
bundle exec ruby features/08-models-and-providers/08-meteora-icon-price/icon_price_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider. The registry entry is
`gemini-2.5-flash-image` on Gemini.
