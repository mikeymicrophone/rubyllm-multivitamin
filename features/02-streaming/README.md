# Streaming

Pass a block to `ask` and RubyLLM yields a `RubyLLM::Chunk` for each piece. `Chunk` inherits `RubyLLM::Message`, so the block reads `chunk.content`. When the stream finishes, `ask` returns the accumulated message. `chunk.tool_calls` can hold a partial argument string; wait for the complete call (a callback, not the chunk) before running a tool. `chat.cancel` raises `RubyLLM::CancelledError`, which inherits `StandardError` rather than `RubyLLM::Error`.

The encoder sets `stream: true` and `stream_options: { include_usage: true }` on Chat Completions.

Official reference: [Streaming](https://rubyllm.com/streaming/).

## Free models

Default `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `google/gemma-4-31b-it:free`. Checked 14 October 2026. These thirteen cassettes were re-recorded on OpenAI `gpt-4.1-mini` after the `:free` slugs hit `free-models-per-day`. OpenAI streams the Responses API as `response.output_text.delta` events. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.

## Examples (13 of 13 bottled)

01. [Muscat date-pack dictation](01-muscat-date-pack/) — available
02. [Reykjavík geothermal well log](02-reykjavik-well-log/) — available
03. [Kathmandu brick kiln climb](03-kathmandu-kiln-climb/) — available
04. [Angkor stone-join steps](04-angkor-stone-join/) — available
05. [Paranal shutter timing](05-paranal-shutter-timing/) — available
06. [Kigali drone corridor check](06-kigali-corridor-check/) — available
07. [Ulaanbaatar cashmere chant](07-ulaanbaatar-cashmere-chant/) — available
08. [Fez tannery pit halt](08-fez-tannery-halt/) — available
09. [Christchurch Alpine Fault warning](09-christchurch-fault-warning/) — available
10. [Sheffield cutlery heat-lot](10-sheffield-heat-lot/) — available
11. [Prague marionette handover](11-prague-marionette-handover/) — available
12. [Rio Carnival bloco broadcast](12-rio-bloco-broadcast/) — available
13. [Kiruna skip-hoist relief](13-kiruna-skip-relief/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | A block on `ask`; chunk `content`, `thinking`, `model`, and tokens on the usage chunk |
| 02 | Print chunks to a terminal; the cassette is an SSE body and a second pass matches |
| 03 | Temperatures split across chunks; the join equals the returned message |
| 04 | Ordered stone-join steps survive a mid-sentence flush; the returned message is the assistant turn |
| 05 | Empty and reasoning-only chunks are not spoken; a tight cap can clip the timing |
| 06 | Token counts arrive on the last chunk |
| 07 | A long chant; write the pieces to an IO and pull them from an Enumerator |
| 08 | `chat.cancel` raises `CancelledError` at the next chunk; the assistant turn is not appended |
| 09 | The fault is named from the joined speech; first-token latency is the first spoken chunk |
| 10 | A lot code is read from the join when a flush lands mid-code |
| 11 | Two streamed asks on one chat; the second request includes the first answer |
| 12 | Broadcast each spoken chunk to subscribed escolas, in plain Ruby |
| 13 | Capstone: a streamed tool call with partial arguments, then cancel the spoken relief |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
