# Discoveries

Non-obvious RubyLLM behaviors found while bottling this catalog, plus notes
on running the examples and provider gotchas that show up inside those
examples. Every entry was confirmed by a test in this repository against
**RubyLLM 2.1.1**. Nothing is written here from the guides alone, and nothing
is written here until a test has shown it.

Each entry has a short title, what happens, why it matters, what to do about
it, and a link to the scenario that shows it.

## Chat basics

### A tight output cap can come back with empty content

**What happens.** On `nvidia/nemotron-3-super-120b-a12b:free`, `with_max_output_tokens(64)` returned HTTP 200 and a message whose `content` is `nil` and whose `finish_reason` is `:max_tokens` (`max_tokens?` is true). The provider reported `completion_tokens` 64 and `reasoning_tokens` 64, so the whole cap was reasoning. The draft of the answer is on `message.thinking.text`. `ask` returns that message. It does not raise, and it does not wait for a `content` string.

**Why it matters.** A watch that only prints `content` posts a blank chart note and treats the turn as missing. The turn is in `chat.messages`. The next `ask` sends it again, including the `reasoning_details` array, even though the visible note was empty.

**What to do.** Before posting a reply, treat nil or blank `content`, or `max_tokens?`, as a note that was cut off. Read `thinking` if you need to see what the model had started. Clear the cap with `with_max_output_tokens(nil)` and `ask` again. Read `raw.status` when you want the HTTP status beside the parsed message. `raw.status` was 200 for both the empty note and the posted correction.

Shown in [Chart correction for the Strait of Juan de Fuca](features/01-chat-basics/12-juan-de-fuca-chart-correction/).

## Streaming

### Reasoning arrives as chunks whose content is an empty string

**What happens.** With thinking left on, a streamed `ask` to `nvidia/nemotron-3-super-120b-a12b:free` yields reasoning before the spoken words. Those chunks have `content` equal to `""` and a `thinking.text` delta. `""` is truthy in Ruby, so `if chunk.content` does not skip them. Joining every `content` equals `message.content`. Joining every `thinking.text` equals `message.thinking.text`. Every chunk's `model` is the slug, including `:free`. `with_thinking(false)` sends `"reasoning":{"enabled":false}` and the blast log collects no thinking chunks.

**Why it matters.** A watch that prints every truthy `content` posts a blank line for each reasoning delta.

**What to do.** Speak a chunk only when `content` is non-empty. Read `thinking.text` for the reasoning. Turn thinking off when the log is only the spoken card.

Shown in [Point Wilson tide dictation](features/02-streaming/01-point-wilson-tide-dictation/) and [Cape Disappointment blast log](features/02-streaming/02-cape-disappointment-blast-log/).

### Token counts arrive on the last chunk

**What happens.** A block on `ask` sends `"stream":true` and `"stream_options":{"include_usage":true}`. `chunk.tokens` stays nil until the last chunk. An earlier chunk can already carry `finish_reason` while its input tokens are still nil. The last chunk repeats `finish_reason`, and its input, output, and thinking counts match `message.tokens`. On the radio check those three counts are all greater than 0, and `cost` is 0.

**Why it matters.** Reading tokens from the first chunk that has `finish_reason` records a blank usage line.

**What to do.** Read tokens from the message `ask` returns, or from the last chunk.

Shown in [Alden radio check](features/02-streaming/06-alden-radio-check/) and [Point Wilson tide dictation](features/02-streaming/01-point-wilson-tide-dictation/).

### A tight output cap on a stream can return nil content

**What happens.** `with_max_output_tokens(64)` sends `"max_tokens":64`. The clipped gallery timing returned `content` nil, `finish_reason` `:max_tokens` (`max_tokens?` is true), and no spoken pieces. The draft is on `thinking.text`, and that text includes the flash time and the lens name. The SSE body contains `"finish_reason":"length"`. The uncapped request in the same cassette omits `max_tokens`. `ask` returns the message. It does not raise. This is the empty-content cap from the chart correction, seen while the reply is still a stream.

**Why it matters.** A gallery phone that only speaks `content` stays silent and treats the timing as missing. The turn is the returned message, and the draft is on `thinking`.

**What to do.** Treat nil `content`, or `max_tokens?`, as a note that was cut off. Read `thinking.text`. Clear the cap before asking again.

Shown in [Fresnel gallery rotation](features/02-streaming/05-fresnel-gallery-rotation/). See also [Chart correction for the Strait of Juan de Fuca](features/01-chat-basics/12-juan-de-fuca-chart-correction/).

### The first spoken chunk can follow a run of reasoning chunks

**What happens.** On the storm warning, the first non-empty `content` is not the first chunk. Every note before it has empty `content`, and at least one of those notes has `thinking`. The clock taken at that first spoken chunk is at or after the clock taken when `ask` started, and the finish clock is at or after the spoken clock. The test locks that order. It does not lock a millisecond.

**Why it matters.** A first-token timer that waits for non-empty `content` includes the reasoning chunks. On a cassette replay that interval is parse time, not the network wait from the live recording.

**What to do.** Start the spoken clock on the first non-empty `content`. Assert the order of the clocks, not a duration, when the run is a replay.

Shown in [Admiralty Inlet storm warning](features/02-streaming/09-admiralty-inlet-storm-warning/).

### chat.cancel raises at the next chunk, and the cassette keeps the rest

**What happens.** `chat.cancel` does not raise inside the block. After the block returns, the next chunk checkpoint raises `RubyLLM::CancelledError` with the message `Chat generation cancelled`. That class inherits `StandardError`. It does not inherit `RubyLLM::Error`. The assistant turn is not appended: after the Dungeness halt, `chat.messages` is still `[:system, :user]`. The recorded SSE body still contains the later content deltas. The two pieces the block kept are the first two non-empty `delta.content` values. Replay stops at that same prefix. After a tool message is already on the chat, the same error leaves the roles at `[:system, :user, :assistant, :tool]`.

**Why it matters.** A rescue of `RubyLLM::Error` does not catch the halt. A reader that assumes the cassette ends where the Ruby call ended will replay soundings the mate never logged.

**What to do.** Rescue `RubyLLM::CancelledError` on its own. Treat the cancelled assistant turn as absent. Expect the cassette to hold the full HTTP body; this catalog's player reads that body before chunks are yielded.

Shown in [Dungeness sounding halt](features/02-streaming/08-dungeness-sounding-halt/) and [Cape Disappointment horn relief](features/02-streaming/13-cape-disappointment-relief/).

### A streamed tool call yields argument strings, then a Hash

**What happens.** Chunks for a forced tool call carry `arguments` as a String. One chunk has the tool name and `""`. A later chunk can have no name and more of the JSON. `before_tool_call` receives a Hash. `JSON.parse` of the joined fragment strings equals that Hash. The first request names `posted_horn_card` and does not contain the blast or the compressor figure the tool returns.

**Why it matters.** Reading arguments off the first chunk, or running the tool from the chunk, sees an empty string.

**What to do.** Run the tool from the callback. Join the fragment strings only when you are inspecting the stream.

Shown in [Cape Disappointment horn relief](features/02-streaming/13-cape-disappointment-relief/).

## Tools

No entries yet.

## Structured output

No entries yet.

## Multimodal attachments

No entries yet.

## Embeddings

No entries yet.

## Image generation

No entries yet.

## Models and providers

No entries yet.

## Configuration and contexts

No entries yet.

## Rails integration

No entries yet.

## Instructions and history

No entries yet.

## Tokens and cost

No entries yet.

## Error handling

No entries yet.

## Running the examples

### A non-ASCII SSE body is stored as YAML !binary

**What happens.** The tide-dictation cassette contains U+202F, and VCR wrote that response body as YAML `!binary`. A raw read of the file does not contain `data:`. `YAML.load_file` returns the body, and forcing UTF-8 shows the `data:` lines and the narrow space. One delta ends in `0.4\u202f` and the next begins with `ft`, so the contiguous `0.4\u202fft` is on the joined speech, not in a single SSE line. An ASCII SSE cassette, such as the blast log, keeps the `data:` lines as plain YAML. Neither file contains `sk-or-`. The placeholder `<OPENROUTER_API_KEY>` is in the raw bytes of both.

**Why it matters.** `grep data:` across `cassettes/*.yml` misses the tide dictation. A test that scans the YAML text for a tide height will not see it.

**What to do.** Load the cassette with YAML and force UTF-8 before reading SSE lines. Keep the secret check on the raw bytes.

Shown in [Point Wilson tide dictation](features/02-streaming/01-point-wilson-tide-dictation/).

### A second play of one cassette returns the same pieces

**What happens.** Playing the blast-log cassette again, with no API key, returns the same pieces and the same speech. The cassette holds one HTTP interaction. Those pieces are the non-empty `delta.content` strings in that SSE body.

**Why it matters.** A catalog run with the key unset is that replay. The test records one interaction, and it compares a second play only when `LIVE` is unset.

**What to do.** Assert the pieces against the stored SSE. Compare a second play only when `LIVE` is unset.

Shown in [Cape Disappointment blast log](features/02-streaming/02-cape-disappointment-blast-log/).

## Provider gotchas

### OpenRouter sends reasoning_details back on the next ask

**What happens.** A first request to `nvidia/nemotron-3-super-120b-a12b:free` has no `reasoning_details`. The response carries a `reasoning` string and a `reasoning_details` array. RubyLLM stores that array on the assistant message and the next request includes it on that message. Confirmed on the retort log, where the second request body contains `reasoning_details` and the first does not, and on the chart correction, where the same replay happens after a turn whose `content` was null.

**Why it matters.** A one-line correction still uploads the previous turn's reasoning. Input tokens grow by that text, not only by the visible reply. An empty `content` is not an empty turn on the wire.

**What to do.** Expect a multi-turn chat on this model to get larger by the reasoning, and keep `max_retries` at 0 when you are recording a fixed number of calls. Do not strip the array yourself if a later turn needs the model to continue; OpenRouter wants it back.

Shown in [Cannery retort log for the morning cook](features/01-chat-basics/04-cannery-retort-log/) and [Chart correction for the Strait of Juan de Fuca](features/01-chat-basics/12-juan-de-fuca-chart-correction/).

### with_max_output_tokens is max_tokens on OpenRouter

**What happens.** The chat that called `with_max_output_tokens(2000)` sent `"max_tokens":2000`. The chat that left the cap unset omitted `max_tokens`. The field is not `max_completion_tokens`. A temperature that was never set is omitted the same way: the unset wind-board request has no `temperature` key, and the chat set to `0.1` sends `"temperature":0.1`.

**Why it matters.** A cassette or a proxy rule that looks for `max_completion_tokens` will not see the cap. A test that assumes every request has a temperature will not match the unset chat.

**What to do.** Assert the chat readers (`temperature`, `max_output_tokens`) and, when the wire shape matters, the keys actually present in the cassette body.

Shown in [Port Townsend ferry slip wind board](features/01-chat-basics/10-port-townsend-ferry-slip-wind-board/).

### This free model puts U+202F beside a number

**What happens.** Replies from `nvidia/nemotron-3-super-120b-a12b:free` often separate a word and a numeral with U+202F (narrow no-break space), as in `basket\u202f3` and `242\u202f°F`. The same character shows up between a numeral and a unit. The Point Wilson tide dictation contains `0.4\u202fft` and `8.1\u202fft`. A Ruby regexp `\s` does not match that character. `[[:space:]]` and `\p{Space}` do. It is not on every number: the Anacortes lot-code stream wrote `Basket 3` with a normal space.

**Why it matters.** `assert_includes reply, "basket 3"` and `/0\.4\sft/` fail on a reply that a person would read as "basket 3" or "0.4 ft".

**What to do.** Match the recorded character, or use `[[:space:]]`, when the assertion is about a word or a unit sitting next to a number.

Shown in [Cannery retort log for the morning cook](features/01-chat-basics/04-cannery-retort-log/) and [Point Wilson tide dictation](features/02-streaming/01-point-wilson-tide-dictation/).
