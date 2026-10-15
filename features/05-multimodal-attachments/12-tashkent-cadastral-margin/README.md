# Multimodal attachments · 12 · Tashkent cadastral margin

The cadastre clerk in Tashkent has a margin scan the plotter saved with
no filename extension. The correction in the margin moves marker QY 0.6
ha west on plot 217.

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
| [`cadastral_margin.rb`](cadastral_margin.rb) | Sniffs the scan and asks about the margin |
| [`cadastral_margin_test.rb`](cadastral_margin_test.rb) | Replays the cassette and checks the sniffed type |
| [`cadastral-margin`](cadastral-margin) | The scan, with no extension |
| [`cassettes/cadastral_margin.yml`](cassettes/cadastral_margin.yml) | The Responses round-trip |

**Sample file**

`cadastral-margin` is a PNG drawn for this catalog with ImageMagick
and DejaVu Sans, saved without an extension. The notice is original.
The cassette stores it as base64.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/12-tashkent-cadastral-margin/cadastral_margin.rb
bundle exec ruby features/05-multimodal-attachments/12-tashkent-cadastral-margin/cadastral_margin_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/12-tashkent-cadastral-margin/cadastral_margin.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `google/gemma-4-31b-it:free`.
