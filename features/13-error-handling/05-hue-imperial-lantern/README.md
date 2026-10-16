# Error handling · 05 · Hue imperial lantern

The festival clerk in Hue posts a silk-frame lantern count through a
strict schema that leaves `spare_wicks` out of `required`. OpenAI
answers HTTP 400. `request_shape` keeps the roles and the sizes. It
does not keep 186 or Gia Hoi.

**What it teaches**

- A malformed structured-output schema is `RubyLLM::BadRequestError`.
- The message names `LanternCount` and the missing `spare_wicks` property.
- `request_shape` and `request_shape.to_h` hold no prompt text, so the
  desk can log the shape.
- `to_h` always has the same keys: provider, model, step, payload_keys,
  thinking_settings, instructions, turn_count, omitted_turns, turns,
  tool_names, tool_rounds, problems.

**Files**

| File | Role |
| --- | --- |
| [`lantern_schema.rb`](lantern_schema.rb) | Sends the broken lantern schema |
| [`lantern_schema_test.rb`](lantern_schema_test.rb) | Replays the 400 and checks the shape |
| [`cassettes/lantern_schema.yml`](cassettes/lantern_schema.yml) | The refused Responses call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/05-hue-imperial-lantern/lantern_schema.rb
bundle exec ruby features/13-error-handling/05-hue-imperial-lantern/lantern_schema_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/05-hue-imperial-lantern/lantern_schema.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
