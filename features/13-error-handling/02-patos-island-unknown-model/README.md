# Error handling · 02 · Patos Island unknown model

The keeper at Patos Island Light, the northernmost station in the San
Juans, looks up a foghorn model the current list does not carry. `find`
raises. The message names `refresh`. This scenario does not call it: an
id that was never assigned is not recovered by pulling a new list.

**What it teaches**

- `RubyLLM.models.find` raises `RubyLLM::ModelNotFoundError` for an unknown
  id.
- The message says to refresh if the model exists at the provider.
- `ModelNotFoundError` inherits `StandardError`, not `RubyLLM::Error`.
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`unknown_foghorn.rb`](unknown_foghorn.rb) | Finds a dropped id and rescues the two error classes |
| [`unknown_foghorn_test.rb`](unknown_foghorn_test.rb) | Checks the message and the superclass |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/02-patos-island-unknown-model/unknown_foghorn.rb
bundle exec ruby features/13-error-handling/02-patos-island-unknown-model/unknown_foghorn_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
