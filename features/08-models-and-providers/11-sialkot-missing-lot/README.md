# Models and providers · 11 · Sialkot missing stitch lot

The stitch desk in Sialkot looks up lot 22, a football order the current
book no longer carries. `find` raises. The message names `refresh`. This
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
| [`missing_lot.rb`](missing_lot.rb) | Finds a dropped id and rescues the two error classes |
| [`missing_lot_test.rb`](missing_lot_test.rb) | Checks the message and the superclass |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/11-sialkot-missing-lot/missing_lot.rb
bundle exec ruby features/08-models-and-providers/11-sialkot-missing-lot/missing_lot_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
