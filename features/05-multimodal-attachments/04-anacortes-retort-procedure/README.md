# Multimodal attachments · 04 · Anacortes retort cook procedure

The retort clerk at the Anacortes cannery reads a one-page cook procedure:
basket 3, 242 F, hold 75 minutes. The page is a PDF.

**What it teaches**

- `ask` takes a PDF with `with:`.
- None of the free OpenRouter chat models advertised `file` input on
  14 October 2026, so the recording uses `gpt-4.1-mini`.
- `auto_upload_large_files` is on. The Responses inline limit is 50 MiB
  (`52_428_800` bytes). This card is far smaller, so the request carries
  `file_data` and does not call `/v1/files`.

**Files**

| File | Role |
| --- | --- |
| [`cook_procedure.rb`](cook_procedure.rb) | Asks about the PDF and reads the attachment size |
| [`cook_procedure_test.rb`](cook_procedure_test.rb) | Replays the cassette and checks `file_data` |
| [`cook-procedure.pdf`](cook-procedure.pdf) | The cook card |
| [`cassettes/cook_procedure.yml`](cassettes/cook_procedure.yml) | The Responses round-trip |

**Sample file**

`cook-procedure.pdf` was written for this catalog as a one-page PDF 1.4
file with Helvetica text. The procedure is original. The base64 in the
cassette is small because the card is under 1 KB. Image and audio
cassettes in this feature are where the base64 shows.

A file over 50 MiB was not recorded. That cassette would have held the
upload body.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/04-anacortes-retort-procedure/cook_procedure.rb
bundle exec ruby features/05-multimodal-attachments/04-anacortes-retort-procedure/cook_procedure_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/04-anacortes-retort-procedure/cook_procedure.rb
```

**Model**

`gpt-4.1-mini` on OpenAI.
