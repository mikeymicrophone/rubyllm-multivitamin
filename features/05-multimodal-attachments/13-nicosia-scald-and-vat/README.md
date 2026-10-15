# Multimodal attachments · 13 · Nicosia scald and vat

The halloumi shop in Nicosia has the vat board and the scald procedure
at the same time. One question asks when the first scald is posted and
how long vat 2 holds.

**What it teaches**

- `with:` takes an image and a PDF together.
- `gpt-4.1-mini` accepts both, so the brief stays on one model. A free
  OpenRouter slug was not used to split the modalities: none of those
  slugs advertised `file` input, and the vision slug was past its daily
  cap.
- The request has `input_image` and `input_file`. The user message
  attachments are `:image`, then `:pdf`.

**Files**

| File | Role |
| --- | --- |
| [`scald_and_vat.rb`](scald_and_vat.rb) | Asks with the photograph and the PDF |
| [`scald_and_vat_test.rb`](scald_and_vat_test.rb) | Replays the cassette and checks both parts |
| [`scald-board.png`](scald-board.png) | The vat board |
| [`scald-procedure.pdf`](scald-procedure.pdf) | Vat 2, hold 40 minutes |
| [`cassettes/scald_and_vat.yml`](cassettes/scald_and_vat.yml) | The Responses round-trip |

**Sample files**

Both files were made for this catalog and live in this folder. The PNG
was drawn with ImageMagick and DejaVu Sans. The PDF is a one-page
PDF 1.4 file with Helvetica text. The cassette stores the PNG as base64.
The PDF base64 is small.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/13-nicosia-scald-and-vat/scald_and_vat.rb
bundle exec ruby features/05-multimodal-attachments/13-nicosia-scald-and-vat/scald_and_vat_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/13-nicosia-scald-and-vat/scald_and_vat.rb
```

**Model**

`gpt-4.1-mini` on OpenAI.
