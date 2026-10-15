# Instructions and history · 07 · Friday Harbor long slip sheet

The marina clerk at the Port of Friday Harbor keeps a two-line
instruction and pastes the whole overnight slip sheet as the user turn,
then names the slip assigned to the seiner Cape Flattery.

**What it teaches**

- The system message stays short. The user message carries the board.
- The answer still names slip 14 and Cape Flattery.

**Files**

| File | Role |
| --- | --- |
| [`slip_sheet.rb`](slip_sheet.rb) | Posts short orders and the long sheet |
| [`slip_sheet_test.rb`](slip_sheet_test.rb) | Replays the cassette and checks lengths |
| [`cassettes/slip_sheet.yml`](cassettes/slip_sheet.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/07-friday-harbor-slip-sheet/slip_sheet.rb
bundle exec ruby features/11-instructions-and-history/07-friday-harbor-slip-sheet/slip_sheet_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/07-friday-harbor-slip-sheet/slip_sheet.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
