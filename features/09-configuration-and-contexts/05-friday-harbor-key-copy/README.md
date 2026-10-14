# Configuration and contexts · 05 · Friday Harbor key copy

The night harbormaster at the Port of Friday Harbor keeps a spare tenant
key on one context and chats on another. The spare is never sent. The
global OpenRouter key is still the live one after the assignment.

**What it teaches**

- Assigning `openrouter_api_key` on the yielded config replaces it only
  on that copy.
- `RubyLLM.config.openrouter_api_key` is the value it had before the
  context block.
- The working context still inherits the global key until it assigns one.

**Files**

| File | Role |
| --- | --- |
| [`key_copy.rb`](key_copy.rb) | Builds a spare-key context and a working marina context |
| [`key_copy_test.rb`](key_copy_test.rb) | Replays the cassette and checks the keys |
| [`cassettes/key_copy.yml`](cassettes/key_copy.yml) | The Chat Completions round-trip from the working context |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/05-friday-harbor-key-copy/key_copy.rb
bundle exec ruby features/09-configuration-and-contexts/05-friday-harbor-key-copy/key_copy_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/05-friday-harbor-key-copy/key_copy.rb
```

**Model**

Recorded on `openai/gpt-4.1-mini` with `provider: :openrouter` because the
`:free` chat slugs were past the daily cap. A 512-token output cap is set
so the request fits this workspace's OpenRouter credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`. Checked 14 October 2026.
