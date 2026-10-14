# Configuration and contexts · 12 · Bell buoy empty context

The spare radio on the Ediz Hook buoy tender has no OpenRouter key. Building
a chat on that empty context raises `RubyLLM::ConfigurationError` before any
HTTP call. The working radio still reads the 11.8 volt ledger.

**What it teaches**

- Clearing `openrouter_api_key` on a context makes that copy unconfigured.
- `ctx.chat` raises `ConfigurationError` locally. The cassette has only the
  working radio's request.
- `ConfigurationError` inherits `StandardError` directly. It is not a
  `RubyLLM::Error`, so a rescue of `RubyLLM::Error` misses it.

**Files**

| File | Role |
| --- | --- |
| [`empty_context.rb`](empty_context.rb) | Clears the spare-radio key, then asks on the global chat |
| [`empty_context_test.rb`](empty_context_test.rb) | Replays the cassette and checks the error class |
| [`cassettes/empty_context.yml`](cassettes/empty_context.yml) | The working radio's Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/12-bell-buoy-empty-context/empty_context.rb
bundle exec ruby features/09-configuration-and-contexts/12-bell-buoy-empty-context/empty_context_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/12-bell-buoy-empty-context/empty_context.rb
```

**Model**

Recorded on `openai/gpt-4.1-mini` with `provider: :openrouter` because the
`:free` chat slugs were past the daily cap. A 512-token output cap is set
so the request fits this workspace's OpenRouter credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`. Checked 14 October 2026.
