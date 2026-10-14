# Configuration and contexts · 02 · New Dungeness default model

The relief keeper at New Dungeness Light asks which drawer holds the spare
bull's-eye twice: once on the configured default chat model, and once on a
named spare slug.

**What it teaches**

- `config.default_model` is the id `RubyLLM.chat` uses when no `model:` is
  given.
- A second chat that names `model:` uses that slug instead of the default.
- Both chats still pass `provider:` and `assume_model_exists: true` for the
  free OpenRouter slugs.

**Files**

| File | Role |
| --- | --- |
| [`default_model.rb`](default_model.rb) | Sets `default_model` and asks the cabinet question twice |
| [`default_model_test.rb`](default_model_test.rb) | Replays the cassette and checks both slugs |
| [`cassettes/default_model.yml`](cassettes/default_model.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/02-new-dungeness-default-model/default_model.rb
bundle exec ruby features/09-configuration-and-contexts/02-new-dungeness-default-model/default_model_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/02-new-dungeness-default-model/default_model.rb
```

**Model**

Default: `nvidia/nemotron-3-super-120b-a12b:free`. Named spare:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
