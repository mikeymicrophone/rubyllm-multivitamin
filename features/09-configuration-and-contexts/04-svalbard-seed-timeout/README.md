# Configuration and contexts · 04 · Svalbard seed-vault timeout

The seed-vault clerk outside Longyearbyen uses a longer `request_timeout`
on one context while the catalog's global timeout stays at two minutes.
The clerk still copies the -18 C logger card for accession SV-180.

**What it teaches**

- `config.request_timeout` on a context is read back from
  `context.config`, not from `RubyLLM.config`.
- The global timeout is unchanged after the context chats.
- Connection settings on a context get their own Faraday connection.

**Files**

| File | Role |
| --- | --- |
| [`vault_timeout.rb`](vault_timeout.rb) | Sets 180s on the vault context and copies the logger card |
| [`vault_timeout_test.rb`](vault_timeout_test.rb) | Replays the cassette and compares the two timeouts |
| [`cassettes/vault_timeout.yml`](cassettes/vault_timeout.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/04-svalbard-seed-timeout/vault_timeout.rb
bundle exec ruby features/09-configuration-and-contexts/04-svalbard-seed-timeout/vault_timeout_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/04-svalbard-seed-timeout/vault_timeout.rb
```

**Model**

Recorded on the free OpenRouter chat slug when the daily cap allows.
`CONFIGURATION_OPENROUTER_PAID=1` records `openai/gpt-4.1-mini` on
OpenRouter. A 512-token output cap is set so a paid request fits this
workspace's credits. Fallback: `LIVE_PROVIDER=openai` records native
`gpt-4.1-mini`.
