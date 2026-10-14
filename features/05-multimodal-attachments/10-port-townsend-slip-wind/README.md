# Multimodal attachments · 10 · Port Townsend slip wind

The slip watch at the Port Townsend ferry landing keeps the wind in a
workbook. Chat Completions cannot send that workbook. The clerk converts
it to a text attachment and asks from that text.

**What it teaches**

- `convert_unsupported_attachments` receives the original attachment and
  returns a `RubyLLM::Attachment`.
- The request contains
  `<file name='slip-wind.txt' mime_type='text/plain'>` and the gust line.
  It does not contain the workbook bytes.
- The user message still holds `slip-wind.xlsx` with type `:document`.
- The sheet reader in this folder is the clerk's converter. It inflates
  the ZIP with raw deflate and reads the shared strings.

**Files**

| File | Role |
| --- | --- |
| [`slip_wind.rb`](slip_wind.rb) | Converts the workbook and asks |
| [`slip_wind_test.rb`](slip_wind_test.rb) | Replays the cassette and checks the sheet reader |
| [`slip-wind.xlsx`](slip-wind.xlsx) | North float gust |
| [`cassettes/slip_wind.yml`](cassettes/slip_wind.yml) | The Chat Completions round-trip |

**Sample file**

`slip-wind.xlsx` is a one-sheet workbook written for this catalog. The
cells are original: north float, gust 28 knots, direction 242 degrees,
clock 06:10.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/10-port-townsend-slip-wind/slip_wind.rb
bundle exec ruby features/05-multimodal-attachments/10-port-townsend-slip-wind/slip_wind_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/10-port-townsend-slip-wind/slip_wind.rb
```

**Model**

`gpt-4.1-mini` on OpenAI, `protocol: :chat_completions`. The Responses
API can send a spreadsheet itself, so this scenario stays on Chat
Completions, where the converter is what lets the question through.
