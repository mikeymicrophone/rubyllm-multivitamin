# Streaming

Pass a block to `ask` and RubyLLM yields a `RubyLLM::Chunk` for each piece. `Chunk` inherits `RubyLLM::Message`, so the block reads `chunk.content`. When the stream finishes, `ask` returns the accumulated message. `chunk.tool_calls` can hold a partial argument string; wait for the complete call (a callback, not the chunk) before running a tool. `chat.cancel` raises `RubyLLM::CancelledError`, which inherits `StandardError` rather than `RubyLLM::Error`.

The encoder sets `stream: true` and `stream_options: { include_usage: true }` on Chat Completions.

Official reference: [Streaming](https://rubyllm.com/streaming/).

## Free models

Same free chat model as chat basics, `nvidia/nemotron-3-super-120b-a12b:free`. Fallbacks: `liquid/lfm-2.5-2.6b:free`, then `google/gemma-4-31b-it:free`. OpenRouter streams Chat Completions as server-sent events for these slugs. Checked 14 October 2026.

The spoken handover was recorded on `gpt-4.1-mini` with `provider: :openai` after the free-model daily limit was exhausted. Re-record that cassette with `LIVE_PROVIDER=openrouter` to put it back on the free slug.

## Examples (13 of 13 bottled)

01. [Point Wilson tide dictation](01-point-wilson-tide-dictation/) — available
02. [Cape Disappointment blast log](02-cape-disappointment-blast-log/) — available
03. [Anacortes retort climb](03-anacortes-retort-climb/) — available
04. [Neah Bay pilot ladder steps](04-neah-bay-ladder-steps/) — available
05. [Fresnel gallery rotation](05-fresnel-gallery-rotation/) — available
06. [Alden radio check](06-alden-radio-check/) — available
07. [Bellingham cold storage chant](07-bellingham-cold-storage-chant/) — available
08. [Dungeness sounding halt](08-dungeness-sounding-halt/) — available
09. [Admiralty Inlet storm warning](09-admiralty-inlet-storm-warning/) — available
10. [Anacortes cannery lot code](10-anacortes-cannery-lot-code/) — available
11. [Point Wilson spoken handover](11-point-wilson-spoken-handover/) — available
12. [Port Townsend watch broadcast](12-port-townsend-watch-broadcast/) — available
13. [Cape Disappointment horn relief](13-cape-disappointment-relief/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | A block on `ask`; chunk `content`, `thinking`, `model`, and tokens on the usage chunk |
| 02 | Print chunks to a terminal; the cassette is an SSE body and a second pass matches |
| 03 | Temperatures split across chunks; the join equals the returned message |
| 04 | Ordered ladder steps survive a mid-sentence flush; the returned message is the assistant turn |
| 05 | Empty and reasoning-only chunks are not spoken; a tight cap can return nil content |
| 06 | Token counts arrive on the last chunk after a stream that asked for usage |
| 07 | A long chant; write the pieces to an IO and pull them from an Enumerator |
| 08 | `chat.cancel` raises `CancelledError` at the next chunk; the assistant turn is not appended |
| 09 | The inlet is named from the joined speech; first-token latency skips reasoning chunks |
| 10 | A lot code is read from the join when a flush lands mid-code |
| 11 | Two streamed asks on one chat; the second request includes the first answer |
| 12 | Broadcast each spoken chunk to subscribed stations, in plain Ruby |
| 13 | Capstone: a streamed tool call with partial arguments, then cancel the spoken relief |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
