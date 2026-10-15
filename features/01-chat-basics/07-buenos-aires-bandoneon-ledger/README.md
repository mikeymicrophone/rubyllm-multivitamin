# Chat basics · 07 · Buenos Aires bandoneón ledger

The reed technician for Orquesta Típica Rivarola reads the bandoneón ledger with `say`, then asks when the next overhaul is. The transcript on the chat is the ledger the technician can read back by role.

**What it teaches**

- `say` is an alias of `ask`. The ledger uses `say` for both turns.
- `chat.messages` holds the system instructions, both user turns, and both replies.
- Each message has a `role` and a `content`. Printing them is the inspection.
- The overhaul question does not repeat the pressure. The second `say` still has it, because the first turn is on the chat.

**Files**

| File | Role |
| --- | --- |
| [`bandoneon_ledger.rb`](bandoneon_ledger.rb) | Says the two ledger questions and keeps the transcript |
| [`bandoneon_ledger_test.rb`](bandoneon_ledger_test.rb) | Replays the cassette and checks the alias, the dates, and the roles |
| [`cassettes/bandoneon_ledger.yml`](cassettes/bandoneon_ledger.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/07-buenos-aires-bandoneon-ledger/bandoneon_ledger.rb
bundle exec ruby features/01-chat-basics/07-buenos-aires-bandoneon-ledger/bandoneon_ledger_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The reed-plate date is 2 April 2026, the bellows is 11.8 kPa, and the overhaul is 3 November 2026. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/07-buenos-aires-bandoneon-ledger/bandoneon_ledger.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
