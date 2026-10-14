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

### The second stream carries the first answer without reasoning_details

**What happens.** On `gpt-4.1-mini`, the first spoken-handover request has no assistant turn and no `reasoning_details`. The second request's `input` includes that assistant turn as `output_text`, and the joined text equals the first message. The SSE body uses `response.output_text.delta`. The cabinet reply does not repeat `07:05`. It still refuses to open the lens cabinet.

**Why it matters.** An OpenRouter check that requires `reasoning_details` on the second turn fails on this model even though the first brief was sent again.

**What to do.** Read the assistant item in `input`. Do not require `reasoning_details` unless the model sent reasoning.

Shown in [Point Wilson spoken handover](features/02-streaming/11-point-wilson-spoken-handover/).

## Tools

### A named tool choice is flat on the Responses API

**What happens.** On `gpt-4.1-mini` with `provider: :openai`, `with_tool_options(choice: TwineStock)` sends `"tool_choice":{"type":"function","name":"twine_stock"}`. The name is not nested under a `function` object. The relief handoff uses the same shape. After the forced call runs, the next request omits `tool_choice`.

**Why it matters.** A cassette check written for Chat Completions looks for `"function":{"name":...}` and misses a forced call that did happen.

**What to do.** Match the flat object on OpenAI's Responses API. Match the nested `function` object on OpenRouter Chat Completions.

Shown in [Port Angeles net loft](features/03-tools/11-port-angeles-net-loft/) and [Admiralty Inlet watch desk](features/03-tools/13-admiralty-inlet-watch-desk/).

### with_thinking(false) raises, and the request still asks for encrypted reasoning

**What happens.** `with_thinking(false)` on `openai/gpt-4.1-mini` raises `ArgumentError` with `no off control` before any HTTP call. The recorded tide-window request therefore does not send `"reasoning":{"enabled":false}`. It does send `"include":["reasoning.encrypted_content"]`. The same include is on the other tools cassettes. None of them contain `reasoning_details`.

**Why it matters.** Copying the OpenRouter thinking-off call into an OpenAI example fails before the tool runs. A reader looking for the OpenRouter reasoning toggle will not find it, and will find an include this model does not fill in.

**What to do.** Skip `with_thinking(false)` on this model. `Multivitamin::Models.quiet_thinking` does that, and still sends the toggle when `LIVE_PROVIDER=openrouter`.

Shown in [Point Wilson tide window](features/03-tools/01-point-wilson-tide-window/).

### A paid OpenAI reply reports a non-zero cost

**What happens.** The tide window's `answer.cost.total` is greater than 0. The free OpenRouter recordings in this catalog report 0.

**Why it matters.** A test that locks `cost` at 0 fails on this cassette.

**What to do.** Assert `cost > 0` for an OpenAI recording.

Shown in [Point Wilson tide window](features/03-tools/01-point-wilson-tide-window/).

### Streamed tool arguments are still strings

**What happens.** The chart-stream cassette contains `response.function_call_arguments.delta`. Chunk `arguments` are strings, including an empty string when the tool name arrives. Joining those strings parses to the Hash `before_tool_call` receives. The tool message content is the JSON string of that Hash.

**Why it matters.** The event name is not a Chat Completions `delta.tool_calls` line. The Ruby objects are the same split the horn relief recorded.

**What to do.** Join the fragment strings. Run the tool from the callback. Look for `response.function_call_arguments.delta` in an OpenAI SSE cassette.

Shown in [Juan de Fuca chart stream](features/03-tools/12-juan-de-fuca-chart-stream/). See also [Cape Disappointment horn relief](features/02-streaming/13-cape-disappointment-relief/).

## Structured output

### A Schematist title is the schema name, and content stays JSON text

**What happens.** `with_schema` on a `Schematist::Schema` subclass sends `text.format.type` `json_schema`. The class `title` becomes `text.format.name` (`posted_tide_board`). A manual hash with no `name` and no `title` is named `response`. A hash that sets `name:` sends that string (`PilotBoardingChecklist`). The schema body on the wire has no `$schema` and no `json-schema.org` dialect URL. `response.content` is still the JSON string. `response.parsed` is a Hash with string keys, and `JSON.parse(content)` equals it. RubyLLM 2.1.1 does not define `RubyLLM::Schema`.

**Why it matters.** A reader looking for a `RubyLLM::Schema` class, or expecting `content` to already be the Hash, will not find that shape in 2.1.1. A test that looks for the name `response` on a titled class will miss the title.

**What to do.** Subclass `Schematist::Schema` or pass a Hash. Read `parsed` for the Hash and `content` for the JSON text. Set `title` or `name:` when the wire name matters.

Shown in [Point Wilson tide heights](features/04-structured-output/01-point-wilson-tide-heights/), [Friday Harbor berth slip](features/04-structured-output/05-friday-harbor-berth-slip/), and [Neah Bay pilot checklist](features/04-structured-output/06-neah-bay-pilot-checklist/).

### Optional properties send strict false, and forcing strict is a 400

**What happens.** A schema with `required: false` leaves that property out of `required` and sends `"strict": false`. The Ediz Hook ticket omitted `replaced_on` and kept `pencil_note`. The same model rejects `"strict": true` when `bearing` is a property and is not in `required`: HTTP 400, `RubyLLM::BadRequestError`, and the message names `ChartCorrection` and `Missing 'bearing'`. An `any_of` of `string` and `null` that stays in `required` sends `"strict": true`, and the parsed bearing is `null`.

**Why it matters.** Leaving a field optional looks like a small schema change and turns off strict mode. Marking the envelope `strict: true` without listing every property fails before a notice is parsed.

**What to do.** Use `required: false` when omission is the point, and expect `strict: false`. When the field must be present and may be empty, use `any_of` of the type and `null` and keep it required.

Shown in [Ediz Hook buoy ticket](features/04-structured-output/07-ediz-hook-buoy-ticket/) and [Juan de Fuca chart reject](features/04-structured-output/12-juan-de-fuca-chart-reject/).

### with_schema(nil) drops the format and keeps the earlier JSON

**What happens.** After a schema turn, `with_schema(nil)` makes the next Responses request omit `text` entirely. That request has no `json_schema`. Its `input` still contains the first answer, including `18.4`. A later `with_schema` sends a different name, `crew_note`. The prose turn does not parse as JSON.

**Why it matters.** Clearing the schema does not clear the conversation. The next model still sees the structured turn. A cassette check that expects every request to carry `json_schema` will fail on the prose turn.

**What to do.** Call `with_schema(nil)` for a prose turn. Read `content` there, not `parsed`. Put the next schema on before the ask that should fill it.

Shown in [Bremerton dry dock gate](features/04-structured-output/09-bremerton-dry-dock-gate/).

### A streamed schema arrives as output_text deltas

**What happens.** `ask` with a block, while a schema is set, sends `"stream": true` and `text.format`. The SSE body contains `response.output_text.delta`. Joining chunk `content` equals `message.content`. `parsed` is the Hash. Direction, knots, and gusts match the board, and the keys are strings.

**Why it matters.** A stream reader that waits for a Hash on each chunk never sees one. The Hash is `parsed` on the message `ask` returns.

**What to do.** Join the chunk strings. Parse the returned message.

Shown in [Port Townsend slip wind](features/04-structured-output/10-port-townsend-slip-wind/).

### Judge posts gpt-6-luna to /v1/decisions, which is not with_schema

**What happens.** `RubyLLM::Judge` with `model "gpt-6-luna", provider: :openai` posts to `https://api.openai.com/v1/decisions`. The body keys are `model`, `input`, and `questions`. There is no `text.format`. A `probability` question is sent as `"type": "predicate"`. A `choice` question sends each declared name as `value` (`three_second_blast`) and the words as `description`. A `score` question labels levels `"0"`, `"1"`, and `"2"`, and the words are descriptions. One call can send a predicate and a choice together. `RubyLLM.config.default_judgment_model` is `jev-latest`. `gpt-4.1-mini` supports `structured_output` and does not support `judgment`. `gpt-6-luna` supports both. `whisper-1` supports neither.

**Why it matters.** Pointing `with_schema` at Luna is a Responses schema call, not the Decisions API. Omitting the model on a Judge uses `jev-latest`, not `gpt-6-luna`. A choice test that looks for the description string as `value` will miss the declared name.

**What to do.** Use `with_schema` when the job is a JSON object. Use `RubyLLM::Judge` with `gpt-6-luna` and `provider: :openai` when the job is a probability, a choice, or a score. Read `probability`, `choice`, and `score` from the judgment. `LIVE_PROVIDER` does not retarget a Judge.

Shown in [Cape Disappointment blast pattern](features/04-structured-output/03-cape-disappointment-blast-pattern/), [Smith Island weather round](features/04-structured-output/08-smith-island-weather-round/), [Port Angeles net ticket](features/04-structured-output/11-port-angeles-net-ticket/), [Juan de Fuca chart reject](features/04-structured-output/12-juan-de-fuca-chart-reject/), and [Admiralty Inlet watch handover](features/04-structured-output/13-admiralty-inlet-watch-handover/).

### A schema and a tool share the request, then the forced choice drops off

**What happens.** The first handover request sends `text.format.name` `watch_handover` and `tool_choice` for `lens_cabinet_latch`. The word `shut` is not in that request's `input`. After the tool runs, the next requests omit `tool_choice` and still send the schema. The follow-up changes `horn` and keeps the boats and the lens crew.

**Why it matters.** A schema does not replace tools, and a forced tool choice does not stay on for the follow-up. The lens-crew fields are not in the question.

**What to do.** Register the tool and the schema on the same chat. Read the tool message for the cabinet. Expect `tool_choice` only on the forced turn.

Shown in [Admiralty Inlet watch handover](features/04-structured-output/13-admiralty-inlet-watch-handover/).

## Multimodal attachments

### A PDF under the Responses inline limit is sent as file_data, twice

**What happens.** `auto_upload_large_files` is true. `RubyLLM::Protocols::Responses::Chat::OPENAI_INLINE_FILE_LIMIT` is 52_428_800. The cook card and the twine invoice are both under 1 KB. Each request goes to `https://api.openai.com/v1/responses` and the user content includes `file_data` with a `data:application/pdf;base64,` URI. There is no `file_id` and no `/v1/files` call. On the twine invoice, the second `ask` attaches nothing. The first user message still holds one attachment and the second holds none, and both request bodies still contain that `file_data`. The second body is larger.

**Why it matters.** A normal procedure card does not take the files API. A follow-up stores the same base64 again. A file over 50 MiB was not recorded; that cassette would have held the upload.

**What to do.** Read `attachment.byte_size` against the inline limit before assuming an upload. Expect `file_data` on later turns.

Shown in [Anacortes retort cook procedure](features/05-multimodal-attachments/04-anacortes-retort-procedure/) and [Port Angeles twine invoice](features/05-multimodal-attachments/11-port-angeles-twine-invoice/).

### :high is detail high on an input_image

**What happens.** `RubyLLM::Attachment.new(path, resolution: :high)` keeps `resolution` as `:high`. The Responses body for `gpt-4.1-mini` contains `"type":"input_image"` and `"detail":"high"`.

**Why it matters.** A cassette check that only looks for the data URI will miss whether the keeper asked for the finer setting.

**What to do.** Assert `resolution` on the attachment and `"detail":"high"` in the request.

Shown in [New Dungeness lens drawer](features/05-multimodal-attachments/02-new-dungeness-lens-drawer/).

### A trusted https image URL is forwarded, not inlined

**What happens.** The Friday Harbor sheet URL ends in `.jpg`. The request contains that URL on `input_image` and does not contain `data:image`. OpenAI fetches the sheet. The cassette stores the URL.

**Why it matters.** A thumbnail URL on the same host failed in a probe with `Error while downloading file`. The original file URL is the one this cassette recorded. The bytes are not in the cassette, so a later change to the remote sheet will not change replay.

**What to do.** Pass a URL the station already trusts, with an extension RubyLLM can name. Do not pass a caller-supplied string.

Shown in [Friday Harbor berth sheet](features/05-multimodal-attachments/05-friday-harbor-berth-sheet/).

### A text file is a file element, not a second image

**What happens.** A `.txt` path beside a photograph becomes a text part whose text is `<file name='weather-round.txt' mime_type='text/plain'>` plus the file bytes. The photograph is a separate `input_image` data URI. The same wrapper is what a converted spreadsheet sends: `<file name='slip-wind.txt' mime_type='text/plain'>`.

**Why it matters.** The model can see the written round only inside that element. A test that searches the cassette for the bare filename will miss it if it does not include the wrapper.

**What to do.** Look for the `<file name=... mime_type=...>` wrapper when the attachment is text.

Shown in [Smith Island barometer round](features/05-multimodal-attachments/08-smith-island-barometer/) and [Port Townsend slip wind](features/05-multimodal-attachments/10-port-townsend-slip-wind/).

### The converter runs for a spreadsheet and does not run for an API refusal

**What happens.** On `gpt-4.1-mini` with `protocol: :chat_completions`, an `.xlsx` file is `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` and type `:document`. `ask` raises `RubyLLM::UnsupportedAttachmentError` before HTTP. `response` is nil. A converter registered on that chat is called once. Returning nil keeps the error. The same protocol formats an MP3 as `input_audio`. The model answers HTTP 400, `Invalid 'messages[0]'. Content blocks are expected to be either text or image_url type.`, which is `RubyLLM::BadRequestError`. The converter on that chat is not called. The cassette has that one 400 and does not contain the workbook.

**Why it matters.** Rescuing only `UnsupportedAttachmentError` misses the model refusing a part the protocol was willing to send. A converter will not turn that 400 into text.

**What to do.** Rescue `UnsupportedAttachmentError` for types the protocol cannot format. Rescue `BadRequestError` when the model rejects a modality. Do not expect the converter to run for the second one.

Shown in [Bremerton sill refusal](features/05-multimodal-attachments/09-bremerton-sill-refusal/).

### The user message keeps the workbook the wire replaced

**What happens.** The slip-wind converter returns a text attachment. The request body contains the gust line inside the file element and does not contain the spreadsheet MIME type. After `ask`, the user message attachment is still `slip-wind.xlsx` with type `:document`.

**Why it matters.** Logging `message.attachments` shows the workbook the clerk handed over, not the text the model read.

**What to do.** Read the request body for the replacement. Read `message.attachments` for the original.

Shown in [Port Townsend slip wind](features/05-multimodal-attachments/10-port-townsend-slip-wind/).

### An extensionless PNG is sniffed as image/png

**What happens.** A path with no extension, whose bytes are a PNG, has `mime_type` `image/png`, `extension` nil, and `type` `:image`. The request uses `data:image/png;base64,` and not `application/octet-stream`. The same bytes saved as `.bin` still have `mime_type` `image/png`. The extension string is `bin`.

**Why it matters.** A plotter that drops the extension still sends an image. A `.bin` name does not force an octet stream when the bytes are a PNG.

**What to do.** Read `Attachment#mime_type` and `Attachment#type` after construction. Do not decide the part from the extension alone.

Shown in [Juan de Fuca margin correction](features/05-multimodal-attachments/12-juan-de-fuca-margin-correction/).

### gpt-audio-mini reports tokens and a nil cost, and the next ask resends the audio

**What happens.** `gpt-audio-mini` answers on Chat Completions. The request contains `input_audio` with `"format":"mp3"`. The response usage includes `audio_tokens`. `tokens.input` is greater than 0. `cost.total` is nil. A second `ask` with no `with:` leaves the second user message with no attachment, and both request bodies still contain one `input_audio` part. The Ediz Hook cassette is about 96 KB because that MP3 is stored twice as base64. The foghorn cassette is about 46 KB for one copy.

**Why it matters.** A test that locks `cost` at 0 fails, and a test that requires `cost > 0` fails too. A follow-up that looks attachment-free on `chat.messages` is not attachment-free on the wire. Image cassettes in this feature are smaller (the tide board PNG is about 8 KB and its cassette is about 17 KB) but they are still mostly the data URI.

**What to do.** Assert the log line and the token count. Allow a nil cost on this model. Expect the earlier audio on the next request.

Shown in [Cape Disappointment foghorn call](features/05-multimodal-attachments/03-cape-disappointment-foghorn-call/) and [Ediz Hook buoy check-in](features/05-multimodal-attachments/07-ediz-hook-buoy-check-in/).

### One model can take the photograph and the PDF

**What happens.** `gpt-4.1-mini` on the Responses API accepts `with:` as an array of the tide-board PNG and the cook-procedure PDF. The user message attachments are `:image`, then `:pdf`. The request contains `input_image` and `input_file`. One call returns both the kelp-ledge time and the hold.

**Why it matters.** The free OpenRouter slugs did not advertise `file` input, so a split across a vision model and a PDF model is not required once the chat is on this id.

**What to do.** Send both files on the same `ask` when the model accepts both modalities.

Shown in [Admiralty Inlet cook and tide](features/05-multimodal-attachments/13-admiralty-inlet-cook-and-tide/).

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
