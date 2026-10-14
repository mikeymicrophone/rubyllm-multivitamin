# Configuration and contexts · 04 · Cape Disappointment request timeout

The horn house below North Head at Cape Disappointment uses a longer
`request_timeout` on one context while the catalog's global timeout stays
at two minutes. The tender still copies the 2-second blast card.

**What it teaches**

- `config.request_timeout` on a context is read back from
  `context.config`, not from `RubyLLM.config`.
- The global timeout is unchanged after the context chats.
- Connection settings on a context get their own Faraday connection.

**Files**

| File | Role |
| --- | --- |
| [`horn_timeout.rb`](horn_timeout.rb) | Sets 180s on the horn context and copies the timing card |
| [`horn_timeout_test.rb`](horn_timeout_test.rb) | Replays the cassette and compares the two timeouts |
| [`cassettes/horn_timeout.yml`](cassettes/horn_timeout.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/04-cape-disappointment-timeout/horn_timeout.rb
bundle exec ruby features/09-configuration-and-contexts/04-cape-disappointment-timeout/horn_timeout_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/04-cape-disappointment-timeout/horn_timeout.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
