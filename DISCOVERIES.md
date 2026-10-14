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

No entries yet.

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

No entries yet.

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

### This free model puts U+202F between a word and a number

**What happens.** Replies from `nvidia/nemotron-3-super-120b-a12b:free` often separate a word and a numeral with U+202F (narrow no-break space), as in `basket\u202f3` and `242\u202f°F`. A Ruby regexp `\s` does not match that character. `[[:space:]]` and `\p{Space}` do.

**Why it matters.** `assert_includes reply, "basket 3"` and `/basket\s3/` fail on a reply that a person would read as "basket 3".

**What to do.** Match the recorded character, or use `[[:space:]]`, when the assertion is about a word sitting next to a number.

Shown in [Cannery retort log for the morning cook](features/01-chat-basics/04-cannery-retort-log/).
