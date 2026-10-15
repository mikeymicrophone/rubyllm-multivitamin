# Error handling · 03 · Cattle Point rejected key

The Cattle Point radio, on the southeast tip of San Juan Island, still
holds last winter's OpenRouter key. The kelp watch asks when the ebb
passes Salmon Bank. The provider answers HTTP 401. The ledger text is
not in `request_shape`.

**What it teaches**

- A rejected key is `RubyLLM::UnauthorizedError`. Status is 401.
- `Error#response` is the Faraday response.
- `request_shape` names roles and sizes. It does not hold the ledger.
- `UnauthorizedError` inherits `RubyLLM::Error`.
- The cassette helper strips the deliberately bad `sk-or-v1-` token.

**Files**

| File | Role |
| --- | --- |
| [`rejected_key.rb`](rejected_key.rb) | Sends the kelp ledger with a rejected key |
| [`rejected_key_test.rb`](rejected_key_test.rb) | Replays the 401 and checks the shape and the scrub |
| [`cassettes/rejected_key.yml`](cassettes/rejected_key.yml) | The refused Chat Completions call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/03-cattle-point-rejected-key/rejected_key.rb
bundle exec ruby features/13-error-handling/03-cattle-point-rejected-key/rejected_key_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/13-error-handling/03-cattle-point-rejected-key/rejected_key.rb
```

The script still sends the rejected token, not the live key. `LIVE=1`
needs a key in the environment only so the cassette helper will start.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. The provider
refuses the key before a model runs. Checked 15 October 2026.
