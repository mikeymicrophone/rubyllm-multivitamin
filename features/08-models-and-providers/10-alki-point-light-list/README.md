# Models and providers · 10 · Alki Point light-list refresh

The keeper at Alki Point Light pulls a fresh catalog from the published
RubyLLM light list instead of working off last month's paper. `refresh`
is that pull. It is a network call. This scenario restores the bundled
snapshot afterwards so later examples keep a stable board.

**What it teaches**

- `RubyLLM.models.refresh` downloads `https://rubyllm.com/models.json`.
- `remote_only: true` skips local providers. No provider key is configured,
  so the merge does not also list OpenRouter or OpenAI.
- `config.model_registry_file` points at a gitignored path under `tmp/`,
  not the user cache.
- A later `load_from_json` of the bundled registry puts the in-memory
  board back. `find` of `gpt-4.1-mini` still works on the refreshed list.

**Files**

| File | Role |
| --- | --- |
| [`light_list_refresh.rb`](light_list_refresh.rb) | Refreshes, samples one id, restores the bundled registry |
| [`light_list_refresh_test.rb`](light_list_refresh_test.rb) | Replays the cassette and checks the URI |
| [`cassettes/light_list_refresh.yml`](cassettes/light_list_refresh.yml) | The published-catalog GET |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/10-alki-point-light-list/light_list_refresh.rb
bundle exec ruby features/08-models-and-providers/10-alki-point-light-list/light_list_refresh_test.rb
```

Replay needs no API key. Re-record with:

```sh
LIVE=1 bundle exec ruby features/08-models-and-providers/10-alki-point-light-list/light_list_refresh_test.rb
```

The published catalog does not need a provider key. Do not hand-author
the cassette.

**Model**

None. `refresh` fetches the catalog; it does not chat.
