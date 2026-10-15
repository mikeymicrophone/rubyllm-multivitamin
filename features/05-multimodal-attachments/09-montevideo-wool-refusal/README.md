# Multimodal attachments · 09 · Montevideo wool refusal

The wool office in Montevideo has a bale workbook and a spoken lot call.
The chat is `gpt-4.1-mini` on Chat Completions, which is the wire this
desk still uses. Neither file is a photograph.

**What it teaches**

- An `.xlsx` attachment raises `RubyLLM::UnsupportedAttachmentError`
  before any HTTP call. The message names the spreadsheet MIME type.
  `response` is nil.
- Chat Completions can format audio, so the lot call is sent. The model
  answers HTTP 400: content blocks are expected to be text or
  `image_url`. That is `RubyLLM::BadRequestError`.
- Each chat registers `convert_unsupported_attachments` and returns nil.
  The workbook calls it once, and the error is still
  `UnsupportedAttachmentError`. The lot call does not call it. A 400
  is not a type the protocol refused to format.

The cassette is the 400 only. The workbook never leaves the process.
The lot MP3 is base64 in that one request.

**Files**

| File | Role |
| --- | --- |
| [`wool_refusal.rb`](wool_refusal.rb) | Tries the workbook, then the lot call |
| [`wool_refusal_test.rb`](wool_refusal_test.rb) | Replays the 400 and checks the local error |
| [`wool-book.xlsx`](wool-book.xlsx) | Bale kilos |
| [`wool-lot.mp3`](wool-lot.mp3) | The spoken lot |
| [`cassettes/wool_refusal.yml`](cassettes/wool_refusal.yml) | The refused Chat Completions call |

**Sample files**

`wool-book.xlsx` is a one-sheet workbook written for this catalog. The
cells are original. `wool-lot.mp3` is speech synthesized with
espeak-ng and encoded with ffmpeg. The words are original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/09-montevideo-wool-refusal/wool_refusal.rb
bundle exec ruby features/05-multimodal-attachments/09-montevideo-wool-refusal/wool_refusal_test.rb
```

The script prints both errors. Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/09-montevideo-wool-refusal/wool_refusal.rb
```

**Model**

`gpt-4.1-mini` on OpenAI, `protocol: :chat_completions`.
