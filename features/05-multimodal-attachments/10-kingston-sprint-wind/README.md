# Multimodal attachments · 10 · Kingston sprint wind

The starter at Kingston National Stadium keeps the wind in a workbook.
Chat Completions cannot send that workbook. The clerk converts it to a
text attachment and asks from that text.

**What it teaches**

- `convert_unsupported_attachments` receives the original attachment and
  returns a `RubyLLM::Attachment`.
- The request contains
  `<file name='sprint-wind.txt' mime_type='text/plain'>` and the gust line.
  It does not contain the workbook bytes.
- The user message still holds `sprint-wind.xlsx` with type `:document`.
- The sheet reader in this folder is the clerk's converter. It inflates
  the ZIP with raw deflate and reads the shared strings.

**Files**

| File | Role |
| --- | --- |
| [`sprint_wind.rb`](sprint_wind.rb) | Converts the workbook and asks |
| [`sprint_wind_test.rb`](sprint_wind_test.rb) | Replays the cassette and checks the sheet reader |
| [`sprint-wind.xlsx`](sprint-wind.xlsx) | East lane gust |
| [`cassettes/sprint_wind.yml`](cassettes/sprint_wind.yml) | The Chat Completions round-trip |

**Sample file**

`sprint-wind.xlsx` is a one-sheet workbook written for this catalog. The
cells are original: east lane, gust 16 knots, direction 95 degrees,
clock 15:40.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/10-kingston-sprint-wind/sprint_wind.rb
bundle exec ruby features/05-multimodal-attachments/10-kingston-sprint-wind/sprint_wind_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/10-kingston-sprint-wind/sprint_wind.rb
```

**Model**

`gpt-4.1-mini` on OpenAI, `protocol: :chat_completions`. The Responses
API can send a spreadsheet itself, so this scenario stays on Chat
Completions, where the converter is what lets the question through.
