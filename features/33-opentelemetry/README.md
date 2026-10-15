# OpenTelemetry

`RubyLLM::OpenTelemetry.enable` starts tracing against the process SDK (`opentelemetry-sdk` + an exporter). Spans follow GenAI conventions: `chat`, `embeddings`, `generate_content`, `transcription`, `ocr`, `rerank`, `moderation`, `judgment`, `execute_tool`, `invoke_workflow`, `ruby_llm.workflow_step`. `RubyLLM.workflow("Answer question")` groups calls. Attributes cover model, tokens, and tool names — never prompts, messages, or credentials. `enable` is process-wide; `disable` stops new spans.

Official reference: [OpenTelemetry](https://rubyllm.com/opentelemetry/).

## RubyLLM 2.1.1 entry points

- `RubyLLM::OpenTelemetry.enable` / `disable`
- `RubyLLM.workflow("Answer question") { |workflow| workflow.step(...) }`
- span names `chat`, `execute_tool`, `invoke_workflow`
- `gen_ai.request.model`, `gen_ai.usage.*`
- no spans for batches, video, research, or raw HTTP

## Providers that can record it

Tracing is local. The nested model call records on whatever provider the example uses (OpenRouter free slugs or OpenAI `gpt-4.1-mini`). Export goes to your OTLP backend (`OTEL_EXPORTER_OTLP_ENDPOINT`), not to OpenRouter. Scenarios that only assert span names against an in-memory exporter need no provider cassette; scenarios that wrap a live `ask` record both the chat cassette and the spans.

## Examples (0 of 13 bottled)

01. Bush Point enable after SDK configure — planned
02. Lagoon Point chat span kind client — planned
03. Mutiny Bay execute_tool child — planned
04. Useless Bay workflow tree — planned
05. Double Bluff no prompt attributes — planned
06. Hood Head streaming span stays open — planned
07. Tala Point fallback gets its own span — planned
08. Termination Point eval trial workflow — planned
09. Port Ludlow disable stops new spans — planned
10. Dabob Bay in-memory exporter — planned
11. Quilcene error.type on raise — planned
12. Dosewallips job context — planned
13. Duckabush trace desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
