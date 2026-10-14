# Multimodal attachments · 13 · Admiralty Inlet cook and tide

The Admiralty Inlet watch has the Point Wilson tide board and the
Anacortes cook procedure at the same time. One question asks when Alden
clears the kelp ledge and how long basket 3 holds.

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
| [`cook_and_tide.rb`](cook_and_tide.rb) | Asks with the photograph and the PDF |
| [`cook_and_tide_test.rb`](cook_and_tide_test.rb) | Replays the cassette and checks both parts |
| [`tide-board.png`](tide-board.png) | The Point Wilson board |
| [`cook-procedure.pdf`](cook-procedure.pdf) | Basket 3, 242 F, hold 75 minutes |
| [`cassettes/cook_and_tide.yml`](cassettes/cook_and_tide.yml) | The Responses round-trip |

**Sample files**

Both files were made for this catalog and live in this folder. The PNG
was drawn with ImageMagick and DejaVu Sans. The PDF is a one-page
PDF 1.4 file with Helvetica text. The cassette stores the PNG as base64.
The PDF base64 is small.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/13-admiralty-inlet-cook-and-tide/cook_and_tide.rb
bundle exec ruby features/05-multimodal-attachments/13-admiralty-inlet-cook-and-tide/cook_and_tide_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/13-admiralty-inlet-cook-and-tide/cook_and_tide.rb
```

**Model**

`gpt-4.1-mini` on OpenAI.
