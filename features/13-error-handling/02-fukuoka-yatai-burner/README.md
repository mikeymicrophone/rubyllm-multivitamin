# Error handling · 02 · Fukuoka yatai burner

The stall cook on Nakasu, Fukuoka's riverside yatai row, looks up a
burner model the current list does not carry. `find` raises. The
message names `refresh`. This scenario does not call it: an id that was
never assigned is not recovered by pulling a new list.

**What it teaches**

- `RubyLLM.models.find` raises `RubyLLM::ModelNotFoundError` for an unknown
  id.
- The message says to refresh if the model exists at the provider.
- `ModelNotFoundError` inherits `StandardError`, not `RubyLLM::Error`.
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`yatai_burner.rb`](yatai_burner.rb) | Finds a dropped id and rescues the two error classes |
| [`yatai_burner_test.rb`](yatai_burner_test.rb) | Checks the message and the superclass |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/02-fukuoka-yatai-burner/yatai_burner.rb
bundle exec ruby features/13-error-handling/02-fukuoka-yatai-burner/yatai_burner_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
