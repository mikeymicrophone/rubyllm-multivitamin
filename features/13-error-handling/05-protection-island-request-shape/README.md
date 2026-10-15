# Error handling · 05 · Protection Island request shape

The refuge clerk on Protection Island posts a rhinoceros-auklet count
through a strict schema that leaves `fledglings` out of `required`.
OpenAI answers HTTP 400. `request_shape` keeps the roles and the sizes.
It does not keep 412 or Violet Point.

**What it teaches**

- A malformed structured-output schema is `RubyLLM::BadRequestError`.
- The message names `SeabirdCount` and the missing `fledglings` property.
- `request_shape` and `request_shape.to_h` hold no prompt text, so the
  desk can log the shape.
- `to_h` always has the same keys: provider, model, step, payload_keys,
  thinking_settings, instructions, turn_count, omitted_turns, turns,
  tool_names, tool_rounds, problems.

**Files**

| File | Role |
| --- | --- |
| [`seabird_schema.rb`](seabird_schema.rb) | Sends the broken auklet schema |
| [`seabird_schema_test.rb`](seabird_schema_test.rb) | Replays the 400 and checks the shape |
| [`cassettes/seabird_schema.yml`](cassettes/seabird_schema.yml) | The refused Responses call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/05-protection-island-request-shape/seabird_schema.rb
bundle exec ruby features/13-error-handling/05-protection-island-request-shape/seabird_schema_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/05-protection-island-request-shape/seabird_schema.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 15 October 2026.
