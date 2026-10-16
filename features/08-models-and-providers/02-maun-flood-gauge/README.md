# Models and providers · 02 · Maun flood-gauge clerk

The flood-gauge clerk in Maun looks up `gpt-4.1-mini` the way the Okavango
desk looks up a posted staff height, then reads whether that clerk can
call tools, how wide the window is, and what the posted price is.

**What it teaches**

- `RubyLLM.models.find` returns a `RubyLLM::Model`.
- Bare `find("gpt-4.1-mini")` prefers the first-party `openai` entry.
- `supports?(:function_calling)`, `supports?(:vision)`, and
  `supports?(:structured_output)` are capability checks on that object.
- `context_window`, `max_output_tokens`, `price(:input)`, and
  `price(:output)` are metadata. Prices are USD per million tokens.
- Listing the bundled registry does not open a socket.

**Files**

| File | Role |
| --- | --- |
| [`gauge_clerk.rb`](gauge_clerk.rb) | Finds one model and reads capabilities and price |
| [`gauge_clerk_test.rb`](gauge_clerk_test.rb) | Checks the Maun lookup against the bundled registry |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/02-maun-flood-gauge/gauge_clerk.rb
bundle exec ruby features/08-models-and-providers/02-maun-flood-gauge/gauge_clerk_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider. The registry entry is `gpt-4.1-mini`
on OpenAI.
