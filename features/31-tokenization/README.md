# Tokenization

`RubyLLM.tokenize` returns a `RubyLLM::Tokenization` (`ids`, `count`, `model`, `raw`) for plain text, excluding chat formatting. `RubyLLM.count_tokens` and `chat.count_tokens` count a request (history, instructions, tools, schema, attachments) without generating. Stage a file with `ask_later` before `count_tokens` if the attachment is new. These calls do not predict output length or billed usage; read `response.tokens` after `complete`.

Official reference: [Tokenization](https://rubyllm.com/tokenization/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.tokenize("Ruby makes AI useful.", model:)`
- `tokenization.ids` and `tokenization.count`
- `RubyLLM.count_tokens(prompt, model:)`
- `chat.count_tokens("What should I check?")`
- `ask_later` then `chat.count_tokens` for a new attachment

## Providers that can record it

Tokenize and count_tokens are separate provider endpoints. OpenAI, Anthropic, Gemini/Vertex, Cohere, Mistral, xAI, GPUStack. OpenRouter support is patchy. Feature 12 already bottled billed `response.tokens` after a chat. These scenarios record the counting endpoints. Cheap path: OpenAI `gpt-4.1-mini` for `count_tokens`, or Anthropic `claude-sonnet` when the count must include tools. Unsupported operations raise `RubyLLM::Error`.

## Examples (0 of 13 bottled)

01. Keyport tokenize a hail — planned
02. Poulsbo ids stay ordered — planned
03. Liberty Bay count_tokens prompt — planned
04. Bainbridge chat.count_tokens with instructions — planned
05. Eagle Harbor tools in the count — planned
06. Blakely Rock schema in the count — planned
07. Alki ask_later PDF then count — planned
08. Duwamish tokenize excludes formatting — planned
09. Elliott Bay count vs billed input — planned
10. Shilshole provider_tools omitted — planned
11. Golden Gardens GPUStack proxy — planned
12. Meadow Point Error on unsupported — planned
13. Carkeek count desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
