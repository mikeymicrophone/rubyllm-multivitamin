# Instructions and history · 07 · Vienna pit-part sheet

The pit librarian at the Vienna State Opera keeps a two-line instruction
and pastes the whole overnight folder sheet as the user turn, then names
the folder assigned to the Stadler basset-clarinet part.

**What it teaches**

- The system message stays short. The user message carries the board.
- The answer still names folder 14 and Stadler.

**Files**

| File | Role |
| --- | --- |
| [`pit_sheet.rb`](pit_sheet.rb) | Posts short orders and the long sheet |
| [`pit_sheet_test.rb`](pit_sheet_test.rb) | Replays the cassette and checks lengths |
| [`cassettes/pit_sheet.yml`](cassettes/pit_sheet.yml) | Live recording of the sheet ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/07-vienna-pit-sheet/pit_sheet.rb
bundle exec ruby features/11-instructions-and-history/07-vienna-pit-sheet/pit_sheet_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/07-vienna-pit-sheet/pit_sheet.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
