# Models and providers · 02 · Deception Pass current-table clerk

The current-table clerk at Deception Pass looks up `gpt-4.1-mini` the way
the watch looks up a predicted slack in the whirlpool, then reads whether
that clerk can call tools, how wide the window is, and what the posted
price is.

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
| [`current_clerk.rb`](current_clerk.rb) | Finds one model and reads capabilities and price |
| [`current_clerk_test.rb`](current_clerk_test.rb) | Checks the Deception Pass lookup against the bundled registry |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/02-deception-pass-current-table/current_clerk.rb
bundle exec ruby features/08-models-and-providers/02-deception-pass-current-table/current_clerk_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider. The registry entry is `gpt-4.1-mini`
on OpenAI.
