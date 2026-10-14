# Streaming

Pass a block to `ask` and RubyLLM yields a `RubyLLM::Chunk` for each piece. `Chunk` inherits `RubyLLM::Message`, so the block reads `chunk.content`. When the stream finishes, `ask` returns the accumulated message. `chunk.tool_calls` can hold a partial argument string; wait for the complete call (a callback, not the chunk) before running a tool. `chat.cancel` raises `RubyLLM::CancelledError`, which inherits `StandardError` rather than `RubyLLM::Error`.

The encoder sets `stream: true` and `stream_options: { include_usage: true }` on Chat Completions.

Official reference: [Streaming](https://rubyllm.com/streaming/).

## Free models

Same free chat model as chat basics, `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `google/gemma-4-31b-it:free`. OpenRouter streams Chat Completions as server-sent events for these slugs. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Live dictation of the Point Wilson tide board — planned
02. Foghorn blast log called as it is heard — planned
03. Retort temperature climb during a cook — planned
04. Pilot ladder inspection called step by step — planned
05. Lens rotation timing from the gallery — planned
06. Radio check with the tender, token by token — planned
07. Fish dock auction chant — planned
08. Chart sounding read aloud — planned
09. Storm warning for Admiralty Inlet — planned
10. Cannery label copy streaming a lot code — planned
11. Watch handover spoken while the log is still open — planned
12. A tool pause in the middle of a streamed sounding — planned
13. Cancel the stream when the foghorn watch is relieved — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Accumulate `chunk.content` and compare it with the returned message |
| 02 | Print chunks as they arrive; the cassette is an SSE body |
| 03 | A numeric series (temperatures) split across chunks |
| 04 | Ordered steps that must survive being split mid-sentence |
| 05 | Empty chunks ignored; only text chunks append |
| 06 | The final message's `tokens` after a stream that asked for usage |
| 07 | A long chant, so the block runs more than once |
| 08 | Stop early in the test by cancelling, and rescue `CancelledError` |
| 09 | A warning that names the inlet only if the whole stream is joined |
| 10 | A lot code that must not be split wrong when chunks flush mid-token |
| 11 | Two streamed asks on one chat; the second request includes the first answer |
| 12 | Streaming while a tool runs between model responses |
| 13 | Capstone: stream, a tool, then cancel on the next chunk |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
