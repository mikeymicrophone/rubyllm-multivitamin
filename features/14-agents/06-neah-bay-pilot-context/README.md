# Agents · 06 · Neah Bay pilot context

The mate on the pilot boat Alden, boarding the bulk carrier Silver Kelp off
Neah Bay, uses an agent whose `context` block sets the boat's OpenRouter
title and a 90-second timeout. The catalog's global title stays put.

**What it teaches**

- A zero-argument `context` block defers until the chat is built, so it
  copies the configured key and then overlays the boat title and timeout.
- Chats the agent builds send `X-OpenRouter-Title: Neah Bay pilot boat Alden`.
- `RubyLLM.config.openrouter_app_name` is still the catalog title afterward.
- `agent.context.config.request_timeout` is 90. The global timeout is 120.

**Files**

| File | Role |
| --- | --- |
| [`pilot_context.rb`](pilot_context.rb) | Declares the pilot clerk and the boat context |
| [`pilot_context_test.rb`](pilot_context_test.rb) | Checks the Yes, the headers, and the two timeouts |
| [`cassettes/pilot_context.yml`](cassettes/pilot_context.yml) | The ladder-length round-trip |

**Try it**

```sh
bundle exec ruby features/14-agents/06-neah-bay-pilot-context/pilot_context.rb
bundle exec ruby features/14-agents/06-neah-bay-pilot-context/pilot_context_test.rb
```

**Model**

`openai/gpt-4.1-mini` on OpenRouter (`provider: :openrouter`), so the cassette
keeps `X-OpenRouter-Title` and `HTTP-Referer`. `max_output_tokens` 512 keeps
the paid call cheap. Checked 15 October 2026.
