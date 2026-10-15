# Multimodal attachments

`ask` takes files with `with:`. A value can be a path, a URL, an IO, or an array of those. RubyLLM detects the type from the extension and the bytes. Images, video, audio, text, and PDFs are the documented kinds. Build a `RubyLLM::Attachment` yourself to set `resolution:` (`:low`, `:medium`, `:high`, `:ultra_high`, `:original`). A file the provider cannot send raises `RubyLLM::UnsupportedAttachmentError`. `convert_unsupported_attachments` can swap in a text attachment first.

Pick the model from the modality. A text-only free slug will not do this feature.

Official reference: [Attachments](https://rubyllm.com/attachments/).

## Free models

Images and video in: `google/gemma-4-31b-it:free` (image, text, video). Fallback `google/gemma-4-26b-a4b-it:free`, then `dots-studio/dots-3-note-preview:free` for still images only. Audio in: `thinkingmachines/inkling:free`, then `thinkingmachines/inkling-small:free`, then `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` (audio, image, and video). PDF: no `:free` chat model advertised `file` input on 14 October 2026.

On that afternoon the free slugs answered `Rate limit exceeded: free-models-per-day` before any completion. The bottled cassettes use OpenAI instead. Images, PDFs, and mixed image-and-PDF questions use `gpt-4.1-mini`. Audio uses `gpt-audio-mini`, because `gpt-4.1-mini` on the Responses API raises `UnsupportedAttachmentError` for audio. Re-record a vision or audio scenario on the free slug with `LIVE=1 LIVE_PROVIDER=openrouter` only after changing that scenario's model id. These scripts pin the OpenAI id they were bottled with.

## Examples (13 of 13 bottled)

01. [Sucre cistern board](01-sucre-cistern-board/) — available
02. [Lviv linotype label](02-lviv-linotype-label/) — available
03. [Bamako ngoni call](03-bamako-ngoni-call/) — available
04. [Nuuk ice-core procedure](04-nuuk-ice-core-procedure/) — available
05. [Magelang Borobudur sheet](05-magelang-borobudur-sheet/) — available
06. [Luang Prabang mural](06-luang-prabang-mural/) — available
07. [Penang cable check-in](07-penang-cable-check-in/) — available
08. [Riga schoolyard glass](08-riga-schoolyard-glass/) — available
09. [Montevideo wool refusal](09-montevideo-wool-refusal/) — available
10. [Kingston sprint wind](10-kingston-sprint-wind/) — available
11. [Cebu piña invoice](11-cebu-pina-invoice/) — available
12. [Tashkent cadastral margin](12-tashkent-cadastral-margin/) — available
13. [Nicosia scald and vat](13-nicosia-scald-and-vat/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One local image path and a question about the chalked heights |
| 02 | `resolution: :high` on a small label |
| 03 | One audio file on `gpt-audio-mini` |
| 04 | A PDF on `gpt-4.1-mini`, kept inline under the 50 MiB limit |
| 05 | A URL the scenario trusts, forwarded as that URL |
| 06 | Two images in one `with:` array |
| 07 | A follow-up ask with no new file; the recording is still on the wire |
| 08 | A text file of the round beside the photograph |
| 09 | A spreadsheet raises `UnsupportedAttachmentError`; audio on Chat Completions is HTTP 400, and the converter does not run |
| 10 | A converter that turns a spreadsheet into a text attachment |
| 11 | The same PDF asked twice, so the attachment stays on the first user message and `file_data` is sent again |
| 12 | An extensionless PNG, sniffed as `image/png`; the reply names the margin correction |
| 13 | Capstone: image and PDF together on one model |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
