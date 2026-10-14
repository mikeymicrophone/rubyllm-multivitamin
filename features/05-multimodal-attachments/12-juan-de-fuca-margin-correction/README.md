# Multimodal attachments · 12 · Juan de Fuca margin correction

The chart clerk for the Strait of Juan de Fuca has a margin scan the
plotter saved with no filename extension. The correction in the margin
moves buoy DH 0.4 nm west on chart 18400.

**What it teaches**

- `RubyLLM::Attachment` sniffs `image/png` from the bytes when the path
  has no extension. `extension` is nil and `type` is `:image`.
- The request uses `data:image/png;base64,`, not
  `application/octet-stream`.
- A copy of the same bytes named `.bin` is still `image/png`. The
  extension string is `bin`. That check does not call the model.

**Files**

| File | Role |
| --- | --- |
| [`margin_correction.rb`](margin_correction.rb) | Sniffs the scan and asks about the margin |
| [`margin_correction_test.rb`](margin_correction_test.rb) | Replays the cassette and checks the sniffed type |
| [`margin-correction`](margin-correction) | The scan, with no extension |
| [`cassettes/margin_correction.yml`](cassettes/margin_correction.yml) | The Responses round-trip |

**Sample file**

`margin-correction` is a PNG drawn for this catalog with ImageMagick
and DejaVu Sans, saved without an extension. The notice is original.
The cassette stores it as base64.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/12-juan-de-fuca-margin-correction/margin_correction.rb
bundle exec ruby features/05-multimodal-attachments/12-juan-de-fuca-margin-correction/margin_correction_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/12-juan-de-fuca-margin-correction/margin_correction.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
