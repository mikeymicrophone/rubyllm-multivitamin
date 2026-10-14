# Chat basics · 09 · Bremerton dry dock gate schedule

The yard clerk at Bremerton Marina has the haul-out gate schedule on one chat. "And the tender Retort?" is a fine follow-up there. The same sentence on a fresh chat has no schedule to read.

**What it teaches**

- Reusing a chat sends the gate schedule again, so the follow-up can name Retort's 15:05 flood.
- A new `RubyLLM.chat` starts empty. The same question, with the same instructions, does not contain Cape Flattery or 15:05.
- Instructions tell the fresh chat to say the gate log was not handed over, instead of inventing a time.

**Files**

| File | Role |
| --- | --- |
| [`gate_schedule.rb`](gate_schedule.rb) | Asks the schedule, follows up, then asks the follow-up on a fresh chat |
| [`gate_schedule_test.rb`](gate_schedule_test.rb) | Replays the cassette and checks both chats |
| [`cassettes/gate_schedule.yml`](cassettes/gate_schedule.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/09-bremerton-dry-dock-gate-schedule/gate_schedule.rb
bundle exec ruby features/01-chat-basics/09-bremerton-dry-dock-gate-schedule/gate_schedule_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Cape Flattery floods at 09:15. Retort, on the reused chat, floods at 15:05. The fresh chat says the gate log was not handed over. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/09-bremerton-dry-dock-gate-schedule/gate_schedule.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
