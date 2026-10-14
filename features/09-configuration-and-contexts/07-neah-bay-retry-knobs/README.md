# Configuration and contexts · 07 · Neah Bay retry knobs

The mate on the pilot boat Alden, boarding the bulk carrier Silver Kelp off
Neah Bay, turns Faraday retries off on the boarding context so a ladder
check is one POST. The catalog's global `max_retries` stays at 3.

**What it teaches**

- `max_retries`, `retry_interval`, and `retry_backoff_factor` are copied
  onto a context and do not leak back to `RubyLLM.config`.
- `max_retries` 0 on the cassette context keeps the recording to one
  interaction.
- The global retry count is still the library default after the boarding
  chat.

**Files**

| File | Role |
| --- | --- |
| [`pilot_retries.rb`](pilot_retries.rb) | Sets retry knobs on the boarding context and asks the ladder question |
| [`pilot_retries_test.rb`](pilot_retries_test.rb) | Replays the cassette and checks the knobs |
| [`cassettes/pilot_retries.yml`](cassettes/pilot_retries.yml) | One Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/07-neah-bay-retry-knobs/pilot_retries.rb
bundle exec ruby features/09-configuration-and-contexts/07-neah-bay-retry-knobs/pilot_retries_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/07-neah-bay-retry-knobs/pilot_retries.rb
```

**Model**

Recorded on `openai/gpt-4.1-mini` with `provider: :openrouter` because the
`:free` chat slugs were past the daily cap. A 512-token output cap is set
so the request fits this workspace's OpenRouter credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`. Checked 14 October 2026.
