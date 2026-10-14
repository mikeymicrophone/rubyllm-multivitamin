# Models and providers · 11 · Skagit Bay missing light

The buoy tender in Skagit Bay looks up Light 22, an aid the current list
no longer carries. `find` raises. The message names `refresh`. This
scenario does not call it: a dropped number is not recovered by pulling
a new list.

**What it teaches**

- `RubyLLM.models.find` raises `RubyLLM::ModelNotFoundError` for an unknown
  id.
- The message says to refresh if the model exists at the provider.
- `ModelNotFoundError` inherits `StandardError`, not `RubyLLM::Error`. A
  `rescue RubyLLM::Error` does not catch it.
- This run does not open a socket. There is no cassette file. Recovery is
  application logic.

**Files**

| File | Role |
| --- | --- |
| [`missing_light.rb`](missing_light.rb) | Finds a dropped id and rescues the two error classes |
| [`missing_light_test.rb`](missing_light_test.rb) | Checks the message and the superclass |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/11-skagit-bay-missing-light/missing_light.rb
bundle exec ruby features/08-models-and-providers/11-skagit-bay-missing-light/missing_light_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
