# Instructions and history · 13 · Admiralty Inlet watch reset

The overnight clerk at Point Wilson briefs a running horn off the night
board, then the morning relief assigns `chat.messages = []`, posts new
standing orders, and asks when the foghorn tender Alden can leave the
kelp-ledge float.

**What it teaches**

- Assigning `chat.messages = []` resets the conversation on the same
  chat object.
- A new `with_instructions` after the reset is the only system prompt.
- The next `ask` does not see the overnight board. The morning request
  has 10:46 and does not have 07:05.

**Files**

| File | Role |
| --- | --- |
| [`watch_reset.rb`](watch_reset.rb) | Overnight brief, reset, morning ask |
| [`watch_reset_test.rb`](watch_reset_test.rb) | Replays the cassette and checks the fresh watch |
| [`cassettes/watch_reset.yml`](cassettes/watch_reset.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/13-admiralty-inlet-watch-reset/watch_reset.rb
bundle exec ruby features/11-instructions-and-history/13-admiralty-inlet-watch-reset/watch_reset_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/13-admiralty-inlet-watch-reset/watch_reset.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
