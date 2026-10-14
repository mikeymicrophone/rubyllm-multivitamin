# Chat basics · 07 · Bell buoy maintenance ledger

The buoy tender off Ediz Hook reads the bell buoy ledger with `say`, then asks when the next haul is. The transcript on the chat is the ledger the tender can read back by role.

**What it teaches**

- `say` is an alias of `ask`. The ledger uses `say` for both turns.
- `chat.messages` holds the system instructions, both user turns, and both replies.
- Each message has a `role` and a `content`. Printing them is the inspection.
- The haul question does not repeat the voltage. The second `say` still has it, because the first turn is on the chat.

**Files**

| File | Role |
| --- | --- |
| [`buoy_ledger.rb`](buoy_ledger.rb) | Says the two ledger questions and keeps the transcript |
| [`buoy_ledger_test.rb`](buoy_ledger_test.rb) | Replays the cassette and checks the alias, the dates, and the roles |
| [`cassettes/buoy_ledger.yml`](cassettes/buoy_ledger.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/07-bell-buoy-maintenance-ledger/buoy_ledger.rb
bundle exec ruby features/01-chat-basics/07-bell-buoy-maintenance-ledger/buoy_ledger_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The clapper date is 2 April 2026, the battery is 11.8 volts, and the haul is 3 November 2026. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/07-bell-buoy-maintenance-ledger/buoy_ledger.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
