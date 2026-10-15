# Chat basics · 09 · Mexico City soundstage call sheet

The second AD at Estudios Churubusco has the day's call sheet on one chat. "And the Patio de los Naranjos unit?" is a fine follow-up there. The same sentence on a fresh chat has no sheet to read.

**What it teaches**

- Reusing a chat sends the call sheet again, so the follow-up can name the Patio unit's 15:05 setup.
- A new `RubyLLM.chat` starts empty. The same question, with the same instructions, does not contain Monzón del Palacio or 15:05.
- Instructions tell the fresh chat to say the call sheet was not handed over, instead of inventing a time.

**Files**

| File | Role |
| --- | --- |
| [`call_sheet.rb`](call_sheet.rb) | Asks the sheet, follows up, then asks the follow-up on a fresh chat |
| [`call_sheet_test.rb`](call_sheet_test.rb) | Replays the cassette and checks both chats |
| [`cassettes/call_sheet.yml`](cassettes/call_sheet.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/09-mexico-city-soundstage-call/call_sheet.rb
bundle exec ruby features/01-chat-basics/09-mexico-city-soundstage-call/call_sheet_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Monzón del Palacio sets up at 09:15. The Patio unit, on the reused chat, sets up at 15:05. The fresh chat says the call sheet was not handed over. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/09-mexico-city-soundstage-call/call_sheet.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
