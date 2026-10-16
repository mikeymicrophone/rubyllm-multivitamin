# Instructions and history · 03 · Padua wax cabinet clears instructions

The cabinet clerk at the University of Padua wax rooms answers from the
drawer list under standing orders, then clears those orders when the
afternoon tutorial comes on and asks about the vitrine lamps from
history alone.

**What it teaches**

- `with_instructions(nil)` drops every `:system` message.
- User and assistant turns stay on the chat, so the lamp question
  can still see drawer C.
- The next request has no `instructions` field.

**Files**

| File | Role |
| --- | --- |
| [`cabinet_clear.rb`](cabinet_clear.rb) | Asks the cabinet, clears orders, asks again |
| [`cabinet_clear_test.rb`](cabinet_clear_test.rb) | Replays the cassette and checks the cleared request |
| [`cassettes/cabinet_clear.yml`](cassettes/cabinet_clear.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/03-padua-wax-clear/cabinet_clear.rb
bundle exec ruby features/11-instructions-and-history/03-padua-wax-clear/cabinet_clear_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/03-padua-wax-clear/cabinet_clear.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
