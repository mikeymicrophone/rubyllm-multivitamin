# Files

`RubyLLM.upload` returns a `RubyLLM::UploadedFile` (`id`, `filename`, `byte_size`, `mime_type`, `expires_at`). Pass it to `ask` via `with:`. `RubyLLM::UploadedFile.find` and `RubyLLM.download` round-trip by provider file id. `purpose:` is required on OpenAI/Azure (`"batch"`, `"user_data"`, `"assistants"`). `expires_in:` is seconds. Large chat attachments auto-upload unless `config.auto_upload_large_files = false`.

Official reference: [Files](https://rubyllm.com/files/).

## Models

This catalog records OpenAI Files with `purpose: "user_data"` or `"batch"`, and `gpt-4.1-mini` when a chat reads the file. Anthropic, Gemini, Vertex, Mistral, and DeepSeek need keys or buckets this catalog does not have. OpenAI's inline PDF limit is 50 MiB, so a small mill card stays `file_data` even with automatic uploads on. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Timbuktu salt ledger](01-timbuktu-salt-ledger/) — available
02. [Nelson hops kiln](02-nelson-hops-kiln/) — available
03. [Bridgetown flying fish](03-bridgetown-flying-fish/) — available
04. [Valparaíso funicular](04-valparaiso-funicular/) — available
05. [Lae copra sheet](05-lae-copra-sheet/) — available
06. [Mérida hammock loom](06-merida-hammock-loom/) — available
07. [Ayacucho retablo lot](07-ayacucho-retablo-lot/) — available
08. [Canberra mint blank](08-canberra-mint-blank/) — available
09. [Perth sandalwood chip](09-perth-sandalwood-chip/) — available
10. [Sokoto calabash ridge](10-sokoto-calabash-ridge/) — available
11. [Ghent bobbin lace](11-ghent-bobbin-lace/) — available
12. [Medan durian lot](12-medan-durian-lot/) — available
13. [Salta empanada press](13-salta-empanada-press/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Upload PDF, then `ask` with the `UploadedFile` |
| 02 | `purpose: "batch"` jsonl, no batch job |
| 03 | `expires_in:` one day |
| 04 | `find` and `download` / `save` |
| 05 | Auto-upload on, small PDF stays inline |
| 06 | `auto_upload_large_files = false` |
| 07 | One upload, two asks |
| 08 | One-hour expiry, `expired?` false |
| 09 | IO plus `filename:` |
| 10 | Missing `purpose:` HTTP 400 |
| 11 | Download bytes keep the mill copy |
| 12 | CSV round-trip |
| 13 | Capstone: upload, find, ask, download |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
