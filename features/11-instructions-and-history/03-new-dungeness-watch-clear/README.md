# Instructions and history · 03 · New Dungeness watch clears instructions

The lens keeper at New Dungeness Light answers from the cabinet list
under standing orders, then clears those orders when the relief watch
comes on and asks about the chimneys from history alone.

**What it teaches**

- `with_instructions(nil)` drops every `:system` message.
- User and assistant turns stay on the chat, so the chimney question
  can still see drawer C.
- The next request has no `instructions` field.

**Files**

| File | Role |
| --- | --- |
| [`watch_clear.rb`](watch_clear.rb) | Asks the cabinet, clears orders, asks again |
| [`watch_clear_test.rb`](watch_clear_test.rb) | Replays the cassette and checks the cleared request |
| [`cassettes/watch_clear.yml`](cassettes/watch_clear.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/03-new-dungeness-watch-clear/watch_clear.rb
bundle exec ruby features/11-instructions-and-history/03-new-dungeness-watch-clear/watch_clear_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/03-new-dungeness-watch-clear/watch_clear.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
