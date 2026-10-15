# Files

`RubyLLM.upload` returns a `RubyLLM::UploadedFile` (`id`, `filename`, `byte_size`, `mime_type`, `expires_at`). Pass it to `ask` via `with:`. `RubyLLM::UploadedFile.find` and `RubyLLM.download` round-trip by provider file id. `purpose:` is required on OpenAI/Azure (`"batch"`, `"user_data"`, `"assistants"`). `expires_in:` is seconds. Large chat attachments auto-upload unless `config.auto_upload_large_files = false`.

Official reference: [Files](https://rubyllm.com/files/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.upload("report.pdf", provider: :anthropic)`
- `chat.ask "Summarize", with: file`
- `RubyLLM::UploadedFile.find(id, provider:)`
- `RubyLLM.download(file.id, provider:).save`
- `purpose:`, `expires_in:`, `filename:`
- `config.auto_upload_large_files`

## Providers that can record it

OpenAI and Azure (purpose required). Anthropic (upload; download only of server-created files). Gemini (48h expiry). Mistral (`visibility:`). Vertex AI and Bedrock (bucket `uri:`). xAI, Cohere datasets, ElevenLabs media assets. OpenRouter uploads exist; downloads of your uploads are not offered. This catalog's cheap record path is OpenAI `purpose: "user_data"` plus `gpt-4.1-mini` for the chat that reads the file.

## Examples (0 of 13 bottled)

01. Useless Bay upload then ask — planned
02. Double Bluff purpose batch jsonl — planned
03. Hood Head expires_in a day — planned
04. Tala Point find and download — planned
05. Termination Point auto-upload PDF — planned
06. Port Ludlow auto_upload false — planned
07. Dabob Bay Anthropic reuse — planned
08. Quilcene Gemini 48h — planned
09. Dosewallips IO filename: — planned
10. Duckabush Vertex gs:// uri — planned
11. Hamma Hamma generated CSV download — planned
12. Lilliwaup DeepSeek image download refused — planned
13. Skokomish file desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
