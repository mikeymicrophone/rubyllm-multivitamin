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

Shown in [Accession tag for the Singapore Botanic Gardens](features/01-chat-basics/12-singapore-accession-tag/).

## Streaming

### Reasoning arrives as chunks whose content is an empty string

**What happens.** With thinking left on, a streamed `ask` to `nvidia/nemotron-3-super-120b-a12b:free` yields reasoning before the spoken words. Those chunks have `content` equal to `""` and a `thinking.text` delta. `""` is truthy in Ruby, so `if chunk.content` does not skip them. Joining every `content` equals `message.content`. Joining every `thinking.text` equals `message.thinking.text`. Every chunk's `model` is the slug, including `:free`. `with_thinking(false)` sends `"reasoning":{"enabled":false}` and the well log collects no thinking chunks.

**Why it matters.** A loft that prints every truthy `content` posts a blank line for each reasoning delta.

**What to do.** Speak a chunk only when `content` is non-empty. Read `thinking.text` for the reasoning. Turn thinking off when the log is only the spoken card.

Shown in [Muscat date-pack dictation](features/02-streaming/01-muscat-date-pack/) and [Reykjavík geothermal well log](features/02-streaming/02-reykjavik-well-log/).

### Token counts arrive on the last chunk

**What happens.** A block on `ask` sends `"stream":true` and `"stream_options":{"include_usage":true}`. `chunk.tokens` stays nil until the last chunk. An earlier chunk can already carry `finish_reason` while its input tokens are still nil. The last chunk repeats `finish_reason`, and its input, output, and thinking counts match `message.tokens`. On the corridor check those three counts are all greater than 0, and `cost` is 0.

**Why it matters.** Reading tokens from the first chunk that has `finish_reason` records a blank usage line.

**What to do.** Read tokens from the message `ask` returns, or from the last chunk.

Shown in [Kigali drone corridor check](features/02-streaming/06-kigali-corridor-check/) and [Muscat date-pack dictation](features/02-streaming/01-muscat-date-pack/).

### A tight output cap on a stream can return nil content

**What happens.** `with_max_output_tokens(64)` sends `"max_tokens":64`. The clipped shutter timing returned `content` nil, `finish_reason` `:max_tokens` (`max_tokens?` is true), and no spoken pieces. The draft is on `thinking.text`, and that text includes the open time and the Nasmyth name. The SSE body contains `"finish_reason":"length"`. The uncapped request in the same cassette omits `max_tokens`. `ask` returns the message. It does not raise. This is the empty-content cap from the accession tag, seen while the reply is still a stream.

**Why it matters.** A control phone that only speaks `content` stays silent and treats the timing as missing. The turn is the returned message, and the draft is on `thinking`.

**What to do.** Treat nil `content`, or `max_tokens?`, as a note that was cut off. Read `thinking.text`. Clear the cap before asking again.

Shown in [Paranal shutter timing](features/02-streaming/05-paranal-shutter-timing/). See also [Accession tag for the Singapore Botanic Gardens](features/01-chat-basics/12-singapore-accession-tag/).

### The first spoken chunk can follow a run of reasoning chunks

**What happens.** On the fault warning, the first non-empty `content` is not the first chunk. Every note before it has empty `content`, and at least one of those notes has `thinking`. The clock taken at that first spoken chunk is at or after the clock taken when `ask` started, and the finish clock is at or after the spoken clock. The test locks that order. It does not lock a millisecond.

**Why it matters.** A first-token timer that waits for non-empty `content` includes the reasoning chunks. On a cassette replay that interval is parse time, not the network wait from the live recording.

**What to do.** Start the spoken clock on the first non-empty `content`. Assert the order of the clocks, not a duration, when the run is a replay.

Shown in [Christchurch Alpine Fault warning](features/02-streaming/09-christchurch-fault-warning/).

### chat.cancel raises at the next chunk, and the cassette keeps the rest

**What happens.** `chat.cancel` does not raise inside the block. After the block returns, the next chunk checkpoint raises `RubyLLM::CancelledError` with the message `Chat generation cancelled`. That class inherits `StandardError`. It does not inherit `RubyLLM::Error`. The assistant turn is not appended: after the Fez halt, `chat.messages` is still `[:system, :user]`. The recorded SSE body still contains the later content deltas. The two pieces the block kept are the first two non-empty `delta.content` values. Replay stops at that same prefix. After a tool message is already on the chat, the same error leaves the roles at `[:system, :user, :assistant, :tool]`.

**Why it matters.** A rescue of `RubyLLM::Error` does not catch the halt. A reader that assumes the cassette ends where the Ruby call ended will replay pit readings the master never logged.

**What to do.** Rescue `RubyLLM::CancelledError` on its own. Treat the cancelled assistant turn as absent. Expect the cassette to hold the full HTTP body; this catalog's player reads that body before chunks are yielded.

Shown in [Fez tannery pit halt](features/02-streaming/08-fez-tannery-halt/) and [Kiruna skip-hoist relief](features/02-streaming/13-kiruna-skip-relief/).

### A streamed tool call yields argument strings, then a Hash

**What happens.** Chunks for a forced tool call carry `arguments` as a String. One chunk has the tool name and `""`. A later chunk can have no name and more of the JSON. `before_tool_call` receives a Hash. `JSON.parse` of the joined fragment strings equals that Hash. The first request names `posted_skip_card` and does not contain the cycle or the accumulator figure the tool returns.

**Why it matters.** Reading arguments off the first chunk, or running the tool from the chunk, sees an empty string.

**What to do.** Run the tool from the callback. Join the fragment strings only when you are inspecting the stream.

Shown in [Kiruna skip-hoist relief](features/02-streaming/13-kiruna-skip-relief/).

### The second stream carries the first answer without reasoning_details

**What happens.** On `gpt-4.1-mini`, the first marionette-handover request has no assistant turn and no `reasoning_details`. The second request's `input` includes that assistant turn as `output_text`, and the joined text equals the first message. The SSE body uses `response.output_text.delta`. The loft reply does not repeat `07:05`. It still refuses to open the fly loft.

**Why it matters.** An OpenRouter check that requires `reasoning_details` on the second turn fails on this model even though the first brief was sent again.

**What to do.** Read the assistant item in `input`. Do not require `reasoning_details` unless the model sent reasoning.

Shown in [Prague marionette handover](features/02-streaming/11-prague-marionette-handover/).

## Tools

### A named tool choice is flat on the Responses API

**What happens.** On `gpt-4.1-mini` with `provider: :openai`, `with_tool_options(choice: BallStock)` sends `"tool_choice":{"type":"function","name":"ball_stock"}`. The name is not nested under a `function` object. The relief handoff uses the same shape. After the forced call runs, the next request omits `tool_choice`.

**Why it matters.** A cassette check written for Chat Completions looks for `"function":{"name":...}` and misses a forced call that did happen.

**What to do.** Match the flat object on OpenAI's Responses API. Match the nested `function` object on OpenRouter Chat Completions.

Shown in [Melbourne cricket-net stock](features/03-tools/11-melbourne-cricket-net/) and [Wellington sitting desk](features/03-tools/13-wellington-sitting-desk/).

### with_thinking(false) raises, and the request still asks for encrypted reasoning

**What happens.** `with_thinking(false)` on `openai/gpt-4.1-mini` raises `ArgumentError` with `no off control` before any HTTP call. The recorded auction-board request therefore does not send `"reasoning":{"enabled":false}`. It does send `"include":["reasoning.encrypted_content"]`. The same include is on the other tools cassettes. None of them contain `reasoning_details`.

**Why it matters.** Copying the OpenRouter thinking-off call into an OpenAI example fails before the tool runs. A reader looking for the OpenRouter reasoning toggle will not find it, and will find an include this model does not fill in.

**What to do.** Skip `with_thinking(false)` on this model. `Multivitamin::Models.quiet_thinking` does that, and still sends the toggle when `LIVE_PROVIDER=openrouter`.

Shown in [Addis Ababa coffee-auction chalkboard](features/03-tools/01-addis-ababa-auction-board/).

### A paid OpenAI reply reports a non-zero cost

**What happens.** The auction board's `answer.cost.total` is greater than 0. The free OpenRouter recordings in this catalog report 0.

**Why it matters.** A test that locks `cost` at 0 fails on this cassette.

**What to do.** Assert `cost > 0` for an OpenAI recording.

Shown in [Addis Ababa coffee-auction chalkboard](features/03-tools/01-addis-ababa-auction-board/).

### Streamed tool arguments are still strings

**What happens.** The beam-stream cassette contains `response.function_call_arguments.delta`. Chunk `arguments` are strings, including an empty string when the tool name arrives. Joining those strings parses to the Hash `before_tool_call` receives. The tool message content is the JSON string of that Hash.

**Why it matters.** The event name is not a Chat Completions `delta.tool_calls` line. The Ruby objects are the same split the skip relief recorded.

**What to do.** Join the fragment strings. Run the tool from the callback. Look for `response.function_call_arguments.delta` in an OpenAI SSE cassette.

Shown in [Garching beam-time notice](features/03-tools/12-garching-beam-notice/). See also [Kiruna skip-hoist relief](features/02-streaming/13-kiruna-skip-relief/).

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

**What happens.** `auto_upload_large_files` is true. `RubyLLM::Protocols::Responses::Chat::OPENAI_INLINE_FILE_LIMIT` is 52_428_800. The ice-core card and the piña invoice are both under 1 KB. Each request goes to `https://api.openai.com/v1/responses` and the user content includes `file_data` with a `data:application/pdf;base64,` URI. There is no `file_id` and no `/v1/files` call. On the piña invoice, the second `ask` attaches nothing. The first user message still holds one attachment and the second holds none, and both request bodies still contain that `file_data`. The second body is larger.

**Why it matters.** A normal procedure card does not take the files API. A follow-up stores the same base64 again. A file over 50 MiB was not recorded; that cassette would have held the upload.

**What to do.** Read `attachment.byte_size` against the inline limit before assuming an upload. Expect `file_data` on later turns.

Shown in [Nuuk ice-core procedure](features/05-multimodal-attachments/04-nuuk-ice-core-procedure/) and [Cebu piña invoice](features/05-multimodal-attachments/11-cebu-pina-invoice/).

### :high is detail high on an input_image

**What happens.** `RubyLLM::Attachment.new(path, resolution: :high)` keeps `resolution` as `:high`. The Responses body for `gpt-4.1-mini` contains `"type":"input_image"` and `"detail":"high"`.

**Why it matters.** A cassette check that only looks for the data URI will miss whether the compositor asked for the finer setting.

**What to do.** Assert `resolution` on the attachment and `"detail":"high"` in the request.

Shown in [Lviv linotype label](features/05-multimodal-attachments/02-lviv-linotype-label/).

### A trusted https image URL is forwarded, not inlined

**What happens.** The Magelang Borobudur sheet URL ends in `.jpg`. The request contains that URL on `input_image` and does not contain `data:image`. OpenAI fetches the sheet. The cassette stores the URL.

**Why it matters.** A thumbnail URL on the same host failed in a probe with `Error while downloading file`. The original file URL is the one this cassette recorded. The bytes are not in the cassette, so a later change to the remote sheet will not change replay.

**What to do.** Pass a URL the desk already trusts, with an extension RubyLLM can name. Do not pass a caller-supplied string.

Shown in [Magelang Borobudur sheet](features/05-multimodal-attachments/05-magelang-borobudur-sheet/).

### A text file is a file element, not a second image

**What happens.** A `.txt` path beside a photograph becomes a text part whose text is `<file name='schoolyard-round.txt' mime_type='text/plain'>` plus the file bytes. The photograph is a separate `input_image` data URI. The same wrapper is what a converted spreadsheet sends: `<file name='sprint-wind.txt' mime_type='text/plain'>`.

**Why it matters.** The model can see the written round only inside that element. A test that searches the cassette for the bare filename will miss it if it does not include the wrapper.

**What to do.** Look for the `<file name=... mime_type=...>` wrapper when the attachment is text.

Shown in [Riga schoolyard glass](features/05-multimodal-attachments/08-riga-schoolyard-glass/) and [Kingston sprint wind](features/05-multimodal-attachments/10-kingston-sprint-wind/).

### The converter runs for a spreadsheet and does not run for an API refusal

**What happens.** On `gpt-4.1-mini` with `protocol: :chat_completions`, an `.xlsx` file is `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` and type `:document`. `ask` raises `RubyLLM::UnsupportedAttachmentError` before HTTP. `response` is nil. A converter registered on that chat is called once. Returning nil keeps the error. The same protocol formats an MP3 as `input_audio`. The model answers HTTP 400, `Invalid 'messages[0]'. Content blocks are expected to be either text or image_url type.`, which is `RubyLLM::BadRequestError`. The converter on that chat is not called. The cassette has that one 400 and does not contain the workbook.

**Why it matters.** Rescuing only `UnsupportedAttachmentError` misses the model refusing a part the protocol was willing to send. A converter will not turn that 400 into text.

**What to do.** Rescue `UnsupportedAttachmentError` for types the protocol cannot format. Rescue `BadRequestError` when the model rejects a modality. Do not expect the converter to run for the second one.

Shown in [Montevideo wool refusal](features/05-multimodal-attachments/09-montevideo-wool-refusal/).

### The user message keeps the workbook the wire replaced

**What happens.** The sprint-wind converter returns a text attachment. The request body contains the gust line inside the file element and does not contain the spreadsheet MIME type. After `ask`, the user message attachment is still `sprint-wind.xlsx` with type `:document`.

**Why it matters.** Logging `message.attachments` shows the workbook the clerk handed over, not the text the model read.

**What to do.** Read the request body for the replacement. Read `message.attachments` for the original.

Shown in [Kingston sprint wind](features/05-multimodal-attachments/10-kingston-sprint-wind/).

### An extensionless PNG is sniffed as image/png

**What happens.** A path with no extension, whose bytes are a PNG, has `mime_type` `image/png`, `extension` nil, and `type` `:image`. The request uses `data:image/png;base64,` and not `application/octet-stream`. The same bytes saved as `.bin` still have `mime_type` `image/png`. The extension string is `bin`.

**Why it matters.** A plotter that drops the extension still sends an image. A `.bin` name does not force an octet stream when the bytes are a PNG.

**What to do.** Read `Attachment#mime_type` and `Attachment#type` after construction. Do not decide the part from the extension alone.

Shown in [Tashkent cadastral margin](features/05-multimodal-attachments/12-tashkent-cadastral-margin/).

### gpt-audio-mini reports tokens and a nil cost, and the next ask resends the audio

**What happens.** `gpt-audio-mini` answers on Chat Completions. The request contains `input_audio` with `"format":"mp3"`. The response usage includes `audio_tokens`. `tokens.input` is greater than 0. `cost.total` is nil. A second `ask` with no `with:` leaves the second user message with no attachment, and both request bodies still contain one `input_audio` part. The Penang cassette is about 104 KB because that MP3 is stored twice as base64. The Bamako cassette is about 37 KB for one copy.

**Why it matters.** A test that locks `cost` at 0 fails, and a test that requires `cost > 0` fails too. A follow-up that looks attachment-free on `chat.messages` is not attachment-free on the wire. Image cassettes in this feature are smaller (the cistern board PNG is about 5 KB and its cassette is about 17 KB) but they are still mostly the data URI.

**What to do.** Assert the log line and the token count. Allow a nil cost on this model. Expect the earlier audio on the next request.

Shown in [Bamako ngoni call](features/05-multimodal-attachments/03-bamako-ngoni-call/) and [Penang cable check-in](features/05-multimodal-attachments/07-penang-cable-check-in/).

### One model can take the photograph and the PDF

**What happens.** `gpt-4.1-mini` on the Responses API accepts `with:` as an array of the vat-board PNG and the scald-procedure PDF. The user message attachments are `:image`, then `:pdf`. The request contains `input_image` and `input_file`. One call returns both the first-scald time and the hold.

**Why it matters.** The free OpenRouter slugs did not advertise `file` input, so a split across a vision model and a PDF model is not required once the chat is on this id.

**What to do.** Send both files on the same `ask` when the model accepts both modalities.

Shown in [Nicosia scald and vat](features/05-multimodal-attachments/13-nicosia-scald-and-vat/).

## Embeddings

### An empty string embeds; an empty array is HTTP 400

**What happens.** On `text-embedding-3-small`, `RubyLLM.embed("")` returns HTTP 200 and a 1536-wide vector. `tokens.input` is 0 and `cost.total` is 0. The vector is not all zeros. `RubyLLM.embed([])` raises `RubyLLM::BadRequestError` with `Invalid 'input': input cannot be an empty array.` The cassette holds both round-trips.

**Why it matters.** A watch that treats a blank service card as missing still stores a vector. A watch that treats an empty stack the same way never gets that far.

**What to do.** Treat `""` as a real embedding with zero billed tokens. Rescue `BadRequestError` for `[]`.

Shown in [Ediz Hook buoy service notes](features/06-embeddings/07-ediz-hook-buoy-notes/).

### task_type and title are omitted on OpenAI embeddings

**What happens.** `RubyLLM.embed` accepts `task_type:` and `title:`. OpenAI's Chat Completions embedding payload is `model`, `input`, and optional `dimensions`. The Friday Harbor cassette sends the same remark as `RETRIEVAL_QUERY` and as `RETRIEVAL_DOCUMENT` with a title. Neither request contains `task_type`, `input_type`, `title`, or the retrieval labels. The two vectors are cosine-identical to four places.

**Why it matters.** A retrieval index that depends on query versus document embeddings will not see that split on this provider.

**What to do.** Assert the keys actually present in the cassette. Do not expect OpenAI to honor `task_type:`.

Shown in [Friday Harbor berth remarks](features/06-embeddings/05-friday-harbor-berth-remarks/).

### OpenAI embeddings refuse a PNG before HTTP

**What happens.** `with:` a PNG on `text-embedding-3-small` raises `RubyLLM::UnsupportedAttachmentError` (`Unsupported attachment type: image/png`) before a request is sent. OpenRouter's embeddings protocol accepts the same file: the Smith Island cassette posts `{content: [{type: text}, {type: image_url}]}` to `google/gemini-embedding-2` with `dimensions` 768.

**Why it matters.** Copying `with:` from chat onto OpenAI embeddings fails locally. The error is not `BadRequestError`.

**What to do.** Use a multimodal embedding model for `with:`. Rescue `UnsupportedAttachmentError` on OpenAI embeddings.

Shown in [Smith Island barometer card](features/06-embeddings/08-smith-island-barometer-card/).

## Image generation

### gpt-image-1-mini returns inline bytes, not a URL, and does not rewrite the prompt

**What happens.** `RubyLLM.paint` on `gpt-image-1-mini` fills `image.data` and `image.base64?` is true. `image.url` is `nil`. `image.revised_prompt` is `nil`. The cassette response contains `b64_json` and no hosted `url` and no `revised_prompt` key. The request does not send `response_format`; that parameter is unknown on this model.

**Why it matters.** Code that downloads `image.url`, or that files `revised_prompt` as the prompt that was painted, gets nothing. DALL-E 2 and DALL-E 3, which used to return URLs and (for DALL-E 3) a rewrite, were gone from `https://api.openai.com/v1/models` on 14 October 2026.

**What to do.** Use `save` or `to_blob`. Keep the original prompt if the desk needs a caption. Do not send `response_format`.

Shown in [Cape Disappointment foghorn house](features/07-image-generation/04-cape-disappointment-foghorn-house/) and [Friday Harbor blue hour prompt](features/07-image-generation/06-friday-harbor-blue-hour-prompt/).

### jpeg output still reports mime_type image/png

**What happens.** `provider_options: { output_format: "jpeg" }` is merged onto the payload. The cassette request and response both contain `"output_format":"jpeg"`. `to_blob` starts with JPEG magic (`\xFF\xD8\xFF`). `image.mime_type` is still `"image/png"`. RubyLLM's OpenAI image parser hardcodes that MIME type.

**Why it matters.** Saving as `.png` because `mime_type` says so writes JPEG bytes under a PNG name. A watch that branches on `mime_type` will treat a JPEG plate as PNG.

**What to do.** Read the magic bytes, or the `output_format` in the cassette, when the binder cares about JPEG versus PNG. Do not trust `mime_type` alone on this parser.

Shown in [Anacortes retort floor plate](features/07-image-generation/05-anacortes-retort-floor-plate/).

### tokens are present and cost is nil

**What happens.** The images response includes `usage.input_tokens` and `usage.output_tokens`. `image.tokens.input` and `image.tokens.output` are greater than 0. `image.cost.total`, `image.cost.input`, and `image.cost.output` are `nil`. The bundled registry has no image price for `gpt-image-1-mini`, and the response omits `usage.cost`.

**Why it matters.** A work order that records `cost.total` the way a paid chat does will store nothing. That is not the same as a free chat model's `cost` of `0`.

**What to do.** Record the token counts. Treat `cost.total` as optional. Do not assert `cost > 0` on this model.

Shown in [Bremerton dry dock gate cost](features/07-image-generation/10-bremerton-dry-dock-gate-cost/).

### count: 2 returns an Array; usage lives on the first image

**What happens.** `count: 2` sends `"n":2`. `RubyLLM.paint` returns an Array of two `Image` objects. `tokens.output` on the first is greater than 0. `tokens.output` on the second is `nil`.

**Why it matters.** Summing `cost` or `tokens` across the array double-counts zeros and misses that only the first image carries usage.

**What to do.** Read usage from `images.first`. A default `count` of 1 returns a single `Image`, not a one-element array.

Shown in [Smith Island barometer pair](features/07-image-generation/09-smith-island-barometer-pair/).

### 256x256 is a BadRequestError

**What happens.** `size: "256x256"` on `gpt-image-1-mini` raises `RubyLLM::BadRequestError`. The message names `256x256` and lists `1024x1024`, `1024x1536`, `1536x1024`, and `auto`. The cassette is HTTP 400 and has no `b64_json`.

**Why it matters.** 256 was a DALL-E 2 size. Copying that size onto this model fails before a plate is painted.

**What to do.** Use `1024x1024` as the smallest size. Keep `max_retries` at 0 so Faraday does not double the 400.

Shown in [Juan de Fuca chart size refusal](features/07-image-generation/12-juan-de-fuca-chart-size-refusal/).

## Models and providers

### assume_model_exists still looks up the registry first

**What happens.** `assume_model_exists: true` without `provider:` raises `ArgumentError` (`Provider must be specified if assume_model_exists is true`) before any HTTP call. With a provider, a slug the bundled registry lacks (`commencement-bay-grain-clerk-unlisted`) becomes a synthetic `RubyLLM::Model`: capabilities `function_calling`, `streaming`, `vision`, `structured_output`, `metadata[:warning]` `Assuming model exists, capabilities may not be accurate`, `supports?(:reasoning)` false, `context_window` nil. The same flag on `gpt-4.1-mini`, which `find` already knows, keeps the registry entry: no warning, context window 1_047_576, and the real capability list, which includes `vision` and does not include `streaming`.

**Why it matters.** The model-resolution guide describes assume as skipping the lookup and building a synthetic model. On RubyLLM 2.1.1 the lookup still runs. A watch that reads `metadata[:warning]` or assumes vision is present will see that only when `find` actually missed.

**What to do.** Name `provider:` whenever you assume. Read `context_window` and `supports?` off `chat.model` after construction if the real capabilities matter. Use a slug `find` cannot see when you need the synthetic object.

Shown in [Commencement Bay grain elevator](features/08-models-and-providers/04-commencement-bay-grain-elevator/).

### Bare find of an alias can keep the short id

**What happens.** `find("claude-haiku-4-5")` with no provider returns Anthropic's exact-id entry `claude-haiku-4-5`. `find("claude-haiku-4-5", provider: :anthropic)` resolves the alias table to `claude-haiku-4-5-20251001`. `provider: :bedrock` resolves to `anthropic.claude-haiku-4-5-20251001-v1:0`. The two provider lookups share family `claude-haiku` and a 200_000 token window. The ids are not the same, and the bare id is not the dated Anthropic alias.

**Why it matters.** A watch that records `chat.model.id` after a bare find will not match the dated string the alias table names for Anthropic.

**What to do.** Pass `provider:` when the dated or vendor-prefixed id is the one you need to log.

Shown in [Lime Kiln whale-watch radio alias](features/08-models-and-providers/03-lime-kiln-whale-watch/).

### The Responses API returns a dated snapshot id

**What happens.** `RubyLLM.chat(model: "gpt-4.1-mini", provider: :openai)` sends `"model":"gpt-4.1-mini"`. The message `ask` returns has `model` `gpt-4.1-mini-2025-04-14`. After `with_model("gpt-4o-mini")`, the second request names `gpt-4o-mini` and the second message is `gpt-4o-mini-2024-07-18`. `chat.model.id` stays `gpt-4o-mini`, the id passed to `with_model`.

**Why it matters.** A test that requires `message.model` to equal the request id fails on OpenAI even though the cassette request is correct.

**What to do.** Assert the request body for the id you sent. Treat `message.model` as the snapshot the provider served. Read `chat.model.id` for the id the chat is aimed at.

Shown in [Hood Canal Bridge opening switch](features/08-models-and-providers/05-hood-canal-bridge-opening/).

### ModelNotFoundError is not a RubyLLM::Error

**What happens.** `find("skagit-bay-light-22")` raises `RubyLLM::ModelNotFoundError`. That class's superclass is `StandardError`. A `rescue RubyLLM::Error` around the same call does not catch it. The message names `RubyLLM.models.refresh`. The lookup does not open a socket.

**Why it matters.** A tender who only rescues `RubyLLM::Error` lets a dropped light-list id through. A missing-model lookup does not refresh on its own.

**What to do.** Rescue `ModelNotFoundError` on its own. Call `refresh` only when the application decides the catalog is stale.

Shown in [Skagit Bay missing light](features/08-models-and-providers/11-skagit-bay-missing-light/).

### Models#find is not Enumerable#find

**What happens.** `RubyLLM.models.by_family("claude-sonnet")` is a `Models` object. Calling `.find { |model| model.provider == "anthropic" }` raises `ArgumentError` (`wrong number of arguments (given 0, expected 1)`). `Models#find` looks up an id. `.all.find` with a block is the Enumerable finder and returns an Anthropic entry.

**Why it matters.** A family filter that looks like any other Ruby collection will raise at the watch desk instead of returning the clerk.

**What to do.** Use `.all.find`, `.detect` on the array from `.all`, or `find("claude-sonnet-4-5", provider: :anthropic)` for an id lookup.

Shown in [Sucia Island sonnet family](features/08-models-and-providers/12-sucia-island-sonnet-family/).


## Configuration and contexts

### Provider headers win over with_headers

**What happens.** `with_headers("HTTP-Referer" => "https://www.portoftacoma.com/", "X-Point-Wilson-Watch" => "overnight-kelp-ledge")` stores both on `chat.headers`. The cassette request still sends the configured `openrouter_app_url` as `HTTP-Referer` (`https://www.nps.gov/places/point-wilson-lighthouse.htm`). `X-Point-Wilson-Watch` is on the wire. Faraday merges chat headers first, then `OpenRouter#headers`, so `Authorization`, `HTTP-Referer`, and `X-OpenRouter-Title` cannot be replaced.

**Why it matters.** A tenant that tries to swap the attribution URL from the chat object never changes what OpenRouter records.

**What to do.** Set `openrouter_app_url` and `openrouter_app_name` on the context or global config. Use `with_headers` only for names the provider does not already send.

Shown in [Point Wilson attribution headers](features/09-configuration-and-contexts/01-point-wilson-attribution/).

### Chat has with_provider_options, not with_params

**What happens.** `chat.respond_to?(:with_params)` is false. `chat.respond_to?(:with_provider_options)` is true. `with_provider_options(top_p: 0.2)` merges `"top_p":0.2` onto the Chat Completions body. A second chat that never calls it omits `top_p` and `temperature`.

**Why it matters.** Code copied from older RubyLLM guides that call `with_params` raises `NoMethodError` on 2.1.1.

**What to do.** Call `with_provider_options` for extra request fields. Call `with_temperature` for sampling.

Shown in [Port Townsend sampling and params](features/09-configuration-and-contexts/09-port-townsend-sampling/).

### RubyLLM.logger is memoized from the first Logger it builds

**What happens.** `RubyLLM.logger` is `@logger ||= config.logger || Logger.new(config.log_file, ...)`. After that memo is filled, assigning `config.logger` to a new `StringIO` Logger does not change `RubyLLM.logger`. Faraday's connection cache keys on that memoized object, so request logs keep going to the first Logger. Clearing `RubyLLM.instance_variable_set(:@logger, nil)` makes the next read pick up `config.logger`. Connection settings also include the Logger, so a new Logger gets a new Faraday connection.

**Why it matters.** A station desk that reconfigures `logger` mid-process, or a test that sets a `StringIO` after an earlier example already chatted, never sees those lines.

**What to do.** Set `config.logger` before the first request. If a later block needs a different IO, clear the memo. Restore `File::NULL` and clear the memo when a test finishes so later examples are not flooded.

Shown in [Smith Island logger](features/09-configuration-and-contexts/06-smith-island-logger/).

### ConfigurationError is not a RubyLLM::Error

**What happens.** Clearing `openrouter_api_key` on a context makes `ctx.chat` raise `RubyLLM::ConfigurationError` before any HTTP call. That class inherits `StandardError` directly. `error.is_a?(RubyLLM::Error)` is false. The cassette holds only the working radio's request.

**Why it matters.** `rescue RubyLLM::Error` around `chat.ask` does not catch a missing key. The spare radio looks like a network failure and is not.

**What to do.** Rescue `RubyLLM::ConfigurationError` on its own. Treat it as a local setup miss, not a provider response.

Shown in [Bell buoy empty context](features/09-configuration-and-contexts/12-bell-buoy-empty-context/).

## Rails integration

### acts_as_tool_call and acts_as_model are not application macros

**What happens.** After `ActiveRecord::Base.include RubyLLM::ActiveRecord::ActsAs`, `respond_to?(:acts_as_tool_call)` and `respond_to?(:acts_as_model)` are false. Tool requests persist as `RubyLLM::ActiveRecord::ToolCall` rows in `ruby_llm_tool_calls`. The chat's `model` association is `RubyLLM::ActiveRecord::Model` in `ruby_llm_models`. `assume_model_exists: true` with `provider: :openrouter` still inserts that model row for `nvidia/nemotron-3-super-120b-a12b:free`, a slug the bundled JSON catalog does not list.

**Why it matters.** The older Rails guide, and `main` of the gem, still show application `ToolCall` and `Model` classes with those macros. Copying that setup into 2.1.1 raises `NoMethodError`.

**What to do.** Declare `acts_as_chat` and `acts_as_message` only. Read tool calls from `message.tool_calls` and the registry row from `chat.model`.

Shown in [Friday Harbor berth tool](features/10-rails-integration/05-friday-harbor-berth-tool/) and [Neah Bay pilot slug](features/10-rails-integration/09-neah-bay-pilot-slug/).

### A streamed ask inserts an empty assistant row before the first chunk

**What happens.** `before_message` on the underlying chat, registered after `to_llm`, runs once `persist_new_message` has already created the assistant. That row's `content` is `""`. After the stream, the same row holds the joined speech.

**Why it matters.** A presence validation on `content` raises `ActiveRecord::RecordInvalid` before any token arrives. A watch that reads the assistant mid-stream sees a blank note that later becomes the brief.

**What to do.** Leave content optional. Read the filled row after `ask` returns.

Shown in [Cape Disappointment blast stream](features/10-rails-integration/04-cape-disappointment-blast-stream/) and [Bremerton empty gate](features/10-rails-integration/10-bremerton-empty-gate/).

### cancel on a persisted log destroys the blank assistant

**What happens.** `chat.cancel` during a streamed `ask` sets `cancelled?` true on the record and raises `RubyLLM::CancelledError` (`StandardError`, not `RubyLLM::Error`). After the rescue, `messages` is `[:system, :user]`. The assistant row created for the stream is gone.

**Why it matters.** A rescue of `RubyLLM::Error` misses the halt. A query that expects a partial assistant note will not find one.

**What to do.** Rescue `RubyLLM::CancelledError` on its own. Treat the cancelled assistant turn as absent.

Shown in [Juan de Fuca cancel log](features/10-rails-integration/12-juan-de-fuca-cancel-log/). See also [Fez tannery pit halt](features/02-streaming/08-fez-tannery-halt/).

## Instructions and history

### Replacing instructions appends the new system message at the end

**What happens.** After a morning ask, `chat.messages` is `[:system, :user, :assistant]`. A second `with_instructions` without `append:` rejects the morning system message and `<<` the afternoon one. The Ruby roles are then `[:user, :assistant, :system]`. On OpenAI Responses the encoder still lifts that last system text into `instructions`. The second request contains `afternoon standing orders` and does not contain `morning standing orders`. The 18.4 ft sill from the first user turn is still in `input`.

**Why it matters.** A watch that reads `messages.first` after a swap no longer has the standing orders. A cassette check that expects `input[0]` to be `system` will miss the replacement.

**What to do.** After a replace, read system messages with `messages.select { |m| m.role == :system }`, not `messages.first`. On Responses, assert the `instructions` field.

Shown in [Bremerton afternoon relief](features/11-instructions-and-history/08-bremerton-afternoon-relief/).

### Two system messages join with a blank line on Responses

**What happens.** `append: true` leaves two `:system` entries on `chat.messages`. The Cape Disappointment request sends both texts in one `instructions` string, joined by `\n\n`. `input` starts with the user visibility card. There is no second `role: system` item.

**Why it matters.** A Chat Completions check that counts `"role":"system"` on the wire will count zero on this protocol even though `chat.messages` has two system turns.

**What to do.** Assert the two texts and the `\n\n` join in `instructions`. Read the count from `chat.messages`.

Shown in [Cape Disappointment horn rule appended](features/11-instructions-and-history/02-cape-disappointment-horn-append/).

### add_message seeds a turn without an HTTP call

**What happens.** `add_message(role: :user)` and `add_message(role: :assistant)` append last watch's ladder card. `ask` then makes the only request. That request body contains the seeded `8 steps` and Calder's `9 steps`. The cassette has one interaction.

**Why it matters.** A test that expects one round-trip per transcript turn will fail. The seeded assistant text is on the wire before the model speaks.

**What to do.** Seed with `add_message` when the desk already has a written card. Count HTTP calls from the cassette, not from `chat.messages.length`.

Shown in [Neah Bay seeded ladder card](features/11-instructions-and-history/10-neah-bay-seeded-ladder/).

## Tokens and cost

### The free slug is in the registry at zero dollars, so components are 0.0

**What happens.** `nvidia/nemotron-3-super-120b-a12b:free` is in the bundled registry with `input_per_million` 0 and `output_per_million` 0. OpenRouter also reports `usage.cost` 0. `cost.total` is that reported 0. `cost.input` and `cost.output` are registry estimates of `0.0`, not `nil`. `assume_model_exists` keeps that registry entry. An unlisted clerk built with `RubyLLM::Model.default` has no `price(:input)`. `cost_for` on that clerk still returns `tokens.reported_cost` when it is present. `RubyLLM::Tokens.new(input:, output:)` drops the reported price, and the same unlisted clerk then yields `nil`. Pricing those bare tokens on `gpt-4.1-mini` yields a positive total.

**Why it matters.** A test that expects component costs to be nil on a free slug fails once the slug is catalogued at $0. A watch that treats `cost.total == 0` as "unpriced" cannot tell a reported zero from a registry zero. Repricing without stripping `reported_cost` never reaches the nil path.

**What to do.** Read `tokens.reported_cost` beside `cost.total`. Build a `Tokens` with only the counts when you want a registry estimate. Rescue nothing: `nil` is the missing-price signal.

Shown in [Ballard Locks salmon-count reported price](features/12-tokens-and-cost/07-ballard-locks-salmon-count/) and [Roche Harbor customs-float unpriced clerk](features/12-tokens-and-cost/10-roche-harbor-customs-float/).

### OpenRouter reports cache buckets as zero, not omitted

**What happens.** The first Agate Pass request sends `with_caching(ttl: "5m")`. The response still includes `prompt_tokens_details.cached_tokens` 0 and `cache_write_tokens` 0. `tokens.cache_read` and `tokens.cache_write` are `0`. They are not `nil`. `tokens.thinking` is greater than 0.

**Why it matters.** `if tokens.cache_read` is false for both nil and 0 in some writings, but `nil?` is the omission check. On this slug a first pass is a reported miss, not an omitted field.

**What to do.** Assert the integer the cassette actually stored. Do not coerce with `to_i` to hide a missing bucket; this recording happens to report zero.

Shown in [Agate Pass tidal-race cache and thinking](features/12-tokens-and-cost/06-agate-pass-tidal-race/).

### A cancelled stream can price a parser-default cache_write of zero

**What happens.** Cancelling after two spoken pieces leaves `chat.messages` at `[:system, :user]`. The attempt status is `:cancelled`. `tokens.input` and `tokens.output` stay nil: the usage chunk is later in the cassette and is not applied. The Chat Completions parser still defaults omitted `cache_write` to `0`, so the cancelled entry's `tokens.to_h` is `{cache_write_tokens: 0}`. On the free slug priced at $0 per million, `chat.cost.total` is `0.0`, not nil. Summing `message.tokens.input` on the transcript is 0.

**Why it matters.** The docs say a billed attempt with no defensible usage blanks `chat.cost.total`. This parser default plus a $0 registry rate fills in a zero instead. A watch that only sums messages misses the attempt entirely.

**What to do.** Read `chat.usage_entries` for cancelled work. Treat `cache_write` 0 with nil input as "usage never arrived," not as a free successful call.

Shown in [Turn Point current-halt cancelled usage](features/12-tokens-and-cost/12-turn-point-current-halt/).

### An unknown tool keyword becomes a tool-role error, then a retry

**What happens.** `posted_kelp_card` declares no parameters. The model still called it with `skiff`. `execute` raises through RubyLLM as a tool message whose content is `{"error":"Invalid tool arguments: unknown keyword: skiff"}`. The next request sends that error and the model calls again with `{}`. That second tool message is the harvest card. `chat.tokens` includes both attempts. The spoken answer still has the sack count.

**Why it matters.** A test that takes the first `:tool` message as the card gets the error JSON. The extra attempt is on the chat ledger.

**What to do.** Read every tool message. Expect `chat.tokens.input` to exceed the final answer's input when a bad call was retried.

Shown in [Cattle Point bull-kelp harvest tools](features/12-tokens-and-cost/11-cattle-point-bull-kelp/).


## Error handling

### BadRequestError is not a default fallback

**What happens.** `with_fallbacks` to `gpt-4.1-mini` on an unlisted OpenRouter slug (`hein-bank-shoal-unlisted`, `assume_model_exists: true`) raises `RubyLLM::BadRequestError` (HTTP 400, `not a valid model ID`). The spare model is not tried. `BadRequestError` is not in `RubyLLM::Fallback::DEFAULT_ERRORS`. The same slug with `on: [RubyLLM::BadRequestError]` falls through to OpenAI and returns the sounding.

**Why it matters.** A desk that assumes any provider error hops to the spare model stays on the 400.

**What to do.** Leave the default list for rate limits, server errors, unavailable, overloaded, timeouts, and connection failures. Pass `on:` when a 400 should hop.

Shown in [Hein Bank model fallback](features/13-error-handling/06-hein-bank-model-fallback/).

### An embedding 400 for context length has no request_shape

**What happens.** `RubyLLM.embed` of a 700-cast Partridge Bank log on `text-embedding-3-small` raises `RubyLLM::ContextLengthExceededError`. Status is 400. The message is `Invalid 'input': maximum context length is 8192 tokens.` `request_shape` is nil. Faraday does not retry that class. The cassette is one POST.

**Why it matters.** Rescuing only `BadRequestError` misses the overflow. Logging `request_shape.to_h` on every `RubyLLM::Error` stores nil for embeddings.

**What to do.** Rescue `ContextLengthExceededError` for a pasted log that will not fit. Do not expect a shape on an embedding error.

Shown in [Partridge Bank logbook](features/13-error-handling/07-partridge-bank-logbook/).

### OpenRouter's daily free-model cap is RateLimitError

**What happens.** `poolside/laguna-s-2.1:free` answered HTTP 429 with `Rate limit exceeded: free-models-per-day. Add 10 credits to unlock 1000 free model requests per day`. That is `RubyLLM::RateLimitError`. `max_retries` 0 kept the cassette to one call.

**Why it matters.** The same class covers the daily cap and the shorter upstream-pool 429s. A watch that only matches `Retry-After` will miss this body: the Iceberg Point cassette has no `Retry-After` header.

**What to do.** Rescue `RateLimitError`. Read the message for `free-models-per-day` when the desk needs to know which cap it hit.

Shown in [Iceberg Point rate limit](features/13-error-handling/04-iceberg-point-rate-limit/).

### A context keeps a dead-circuit base off the global config

**What happens.** Pointing `openrouter_api_base` at `127.0.0.1` on `RubyLLM.config` leaves that host on the global config after the example. Later OpenRouter chats in the same process post to the closed sleeper. A `RubyLLM.context` that sets the loopback base leaves `RubyLLM.config.openrouter_api_base` unset.

**Why it matters.** `rake test` loads every bottled example in one process. A leftover loopback base turns later cassette replays into `Faraday::ConnectionFailed`.

**What to do.** Put a dead-circuit `openrouter_api_base` on a context. Assert the global base is not a loopback address when the example finishes.

Shown in [Point No Point retries](features/13-error-handling/11-point-no-point-retries/) and [Foulweather Bluff fallback hooks](features/13-error-handling/12-foulweather-bluff-fallback-hooks/).

## Agents

### rescue_from wraps the instance, not Agent.chat

**What happens.** `SillClerk.new.ask` against the unlisted OpenRouter slug `bremerton-sill-unlisted` hits HTTP 400. The class `rescue_from RubyLLM::BadRequestError` handler runs and returns the posted 4.2-fathom string. `SillClerk.chat` returns a `RubyLLM::Chat`. `SillClerk.chat.ask` with the same card raises `RubyLLM::BadRequestError` (status 400). The handler never sees that call.

**Why it matters.** A desk that rescues on the class and then calls `Agent.chat` still leaves on the 400. `Agent.chat` is the unwrapped chat API.

**What to do.** Call `ask` on an agent instance when `rescue_from` should swallow the error. Use `Agent.chat` when you want the raw `Chat` and the original exception.

Shown in [Bremerton sill rescue](features/14-agents/09-bremerton-sill-rescue/).

### complete? is true until ask_later stages a user turn

**What happens.** A new `WeatherClerk` with only the system prompt has `complete?` true. `ask_later` appends the barometer card, returns the wrapped `RubyLLM::Chat`, and `complete?` is then false. `step` generates once, returns the assistant message, and `complete?` is true again. A second `step` returns `nil`.

**Why it matters.** A loop that treats `complete?` as "the model has answered" will skip a brand-new agent. A second `step` is not an error; it is the same end `complete` waits for.

**What to do.** Stage with `ask_later`, generate with `step`, and stop when `complete?` is true after that step, or when `step` returns `nil`.

Shown in [Smith Island weather loop](features/14-agents/08-smith-island-weather-loop/).

### find reapplies the agent without a second system row

**What happens.** `SlipClerk.create!` then `ask` persists one system turn with the wind board. `SlipClerk.find(id)` returns the same `SlipChat` row. A follow-up `ask` on the found record still sees the 28-knot gust. `slip_turns.where(role: :system).count` stays 1.

**Why it matters.** A watch that expects `find` to persist the class `instructions` again would count two system rows and send the standing orders twice.

**What to do.** Treat `find` as runtime application of the agent. Count system rows on the persisted association, not on the class macro.

Shown in [Port Townsend slip find](features/14-agents/10-port-townsend-slip-find/).

### create! without chat_model raises ArgumentError

**What happens.** `Class.new(RubyLLM::Agent).create!` raises `ArgumentError` whose message includes `chat_model`. `BuoyClerk.create!` after `chat_model BuoyLog` returns the persisted `BuoyLog`.

**Why it matters.** Rails-mode helpers look like class methods on every agent. They are not. The argument error is raised in Ruby, before any HTTP call.

**What to do.** Set `chat_model` before `create`, `create!`, `find`, or `sync_instructions`. Use `Agent.new` / `Agent.chat` when the conversation is not a record.

Shown in [Ediz Hook buoy chat model](features/14-agents/07-ediz-hook-buoy-chat-model/).

## MCP client

### Microsoft Learn Streamable HTTP answers DELETE 405 on close

**What happens.** After a successful `microsoft_docs_search`, `desk.close` sends `DELETE` to `https://learn.microsoft.com/api/mcp`. The cassette status is 405 Method Not Allowed. `conduct` still returns the tide-gauge answer. RubyLLM does not raise.

**Why it matters.** A watch that treats every non-2xx as a failed briefing would abort after the search already ran.

**What to do.** Let `close` finish. Read the cassette for the 405 when you need to prove the session ended.

Shown in [Point Wilson Learn URL](features/15-mcp-client/01-point-wilson-learn-url/).

### Resource#to_attachment names the file from the URI path

**What happens.** `ask(..., with: card)` turns the MCP resource into an `Attachment` whose filename is `File.basename` of the URI path. The Ediz Hook card URI is `watch://ediz-hook/buoy-battery.md`, so the attachment filename is `buoy-battery.md` and its type is `:text`. The Resource still reports `mimeType` `text/markdown` from the server listing. That string is not what the Responses API sniffs.

**Why it matters.** The documented `with: resource` call only reaches the model when the URI path looks like a file the attachment layer understands.

**What to do.** Give the resource a path that ends in `.md` (or another text extension) when the card is markdown. Assert the attachment filename and type, not only `card.mime_type`.

Shown in [Ediz Hook resource attachment](features/15-mcp-client/06-ediz-hook-resource/).

### Deferred MCP tools send tool_search, then the model looks up the gate

**What happens.** `with_mcp(desk, defer: true)` keeps every server tool in both `chat.tools` and `chat.deferred_tools`. The first Responses request on `gpt-5.4-mini` sends each function with `defer_loading: true` and `{type: "tool_search"}`. It does not contain `tool_search_call`. The follow-up request includes `tool_search_call`, `tool_search_output`, and the `current_gate` result `2.8 kn`.

**Why it matters.** The deferred list is still on the chat object. The provider hides the full definitions behind tool search, then the model calls the gate it found.

**What to do.** Point this slot at a model that accepts `tool_search`. Assert `defer_loading` and `tool_search` on the first request, and `tool_search_call` on the follow-up. `LIVE_PROVIDER` does not retarget this recording.

Shown in [Juan de Fuca deferred tool search](features/15-mcp-client/12-juan-de-fuca-defer/).

## Audio transcription

### gpt-transcribe reports duration seconds, not token counts

**What happens.** `RubyLLM.transcribe` on `gpt-transcribe` returns HTTP 200. The response `usage` is `{"type":"duration","seconds":5}`. There is no `input_tokens` or `output_tokens`. `transcription.duration` is that second count. `transcription.tokens.input`, `tokens.output`, and `cost.total` are `nil`. The same duration-only usage is on the silent Mats Mats reel and on the streamed Mystery Bay deltas. `gpt-4o-transcribe-diarize` on the Kilisut Harbor tape reports `usage.type` `tokens` with `input_tokens` and `output_tokens`.

**Why it matters.** A work order that copies `tokens.input` from a chat message onto every transcription stores nothing on the default model. That is not a free chat model's `cost` of `0`.

**What to do.** Read `duration` on `gpt-transcribe`. Read token counts on the diarization model. Treat `nil` cost as unpriced, not as free.

Shown in [Shine Tidal tokens](features/16-audio-transcription/11-shine-tidal-tokens/), [Mats Mats silent tape](features/16-audio-transcription/10-mats-mats-silence/), and [Kilisut Harbor diarized watch](features/16-audio-transcription/08-kilisut-harbor-diarize/).

## Text to speech

### tts-1 returns raw audio, so tokens and cost are nil

**What happens.** `RubyLLM.speak` on `tts-1` fills `speech.to_blob` with MPEG bytes. `speech.tokens.input` and `speech.tokens.output` are `nil`. `speech.cost.total`, `speech.cost.input`, and `speech.cost.output` are `nil`. The cassette response is `audio/mpeg`, not JSON, and does not contain `input_tokens` or `"cost":`. The bundled registry has no speech price for `tts-1`.

**Why it matters.** A work order that records `cost.total` the way a paid chat does will store nothing. That is not the same as a free chat model's `cost` of `0`.

**What to do.** Treat speech usage as optional on this model. Do not assert `tokens.input > 0` or `cost > 0`.

Shown in [Fort Flagler tokens and cost](features/17-text-to-speech/09-fort-flagler-tokens-cost/).

### omitted format leaves response_format off the wire; alloy is still sent

**What happens.** `RubyLLM.speak` without `voice:` or `format:` sends `"model":"tts-1"` and `"voice":"alloy"`. The request does not contain `response_format`. `Speech#format` is still `"mp3"` and `mime_type` is `"audio/mpeg"`. The bytes start with an MPEG frame sync.

**Why it matters.** A test that requires `"response_format":"mp3"` in the cassette will fail even though the clip is MP3. The default voice is not omitted; RubyLLM writes `alloy`.

**What to do.** Assert `Speech#format` and the missing `response_format` key. Name `voice:` when the desk must not be alloy.

Shown in [Fort Worden welcome hail](features/17-text-to-speech/01-fort-worden-welcome-hail/).

### aiff is a BadRequestError

**What happens.** `format: "aiff"` on `tts-1` raises `RubyLLM::BadRequestError`. The message is `Invalid response_format`. The cassette is HTTP 400 and has no audio payload.

**Why it matters.** AIFF is a real recorder format. Copying it onto this model fails before a hail is spoken.

**What to do.** Use `mp3` or `wav`. Keep `max_retries` at 0 so Faraday does not double the 400.

Shown in [Middle Point refused format](features/17-text-to-speech/12-middle-point-refused-format/).

### instructions and speed merge onto tts-1

**What happens.** `provider_options: { instructions: "...", speed: 0.85 }` is merged onto the payload. The Kala Point cassette request contains both `"instructions"` and `"speed":0.85` beside `"model":"tts-1"`. The call returns HTTP 200, not a 400.

**Why it matters.** OpenAI's speech guide says `instructions` does not work with `tts-1` or `tts-1-hd`. RubyLLM still sends the field as-is. A watch that expects a refusal will not see one.

**What to do.** Assert the keys actually present in the cassette. Use `gpt-4o-mini-tts` when the delivery instructions must change the voice.

Shown in [Kala Point speed instructions](features/17-text-to-speech/08-kala-point-speed-instructions/).

## Provider tools and citations

### a completed web_search_call can still have empty citations

**What happens.** `with_provider_tools(:web_search)` on `gpt-4.1-mini` sends `"type":"web_search"`. The Diamond Point hail returns a `web_search_call` and `tokens.server_tool_use["web_search_requests"]` of at least 1. `response.citations` is still empty: the recorded `annotations` array was `[]`. Later hails on the same model fill `url_citation` annotations, and those become `RubyLLM::Citation` objects.

**Why it matters.** A watch that treats a missing citation list as a failed search will throw out a hail that already ran on the provider.

**What to do.** Assert the `web_search_call` and the request count. Treat citations as optional unless the cassette actually recorded annotations.

Shown in [Diamond Point web search hail](features/18-provider-tools-and-citations/01-diamond-point-web-search/) and [Tala Point citation indexes](features/18-provider-tools-and-citations/12-tala-point-citation-indexes/).

### gpt-4.1-mini rejects web_search filters

**What happens.** `with_provider_tools(web_search: { filters: { allowed_domains: ["tidesandcurrents.noaa.gov"] } })` raises `RubyLLM::BadRequestError`. The message mentions `filters`. The cassette status is 400. The same model accepts `search_context_size: "low"`: that request contains `"search_context_size":"low"` and `"type":"web_search"`, and the Sequim hail has citation URLs.

**Why it matters.** Domain filters look like the way to keep the clerk on NOAA. On this model they fail before a page is named.

**What to do.** Keep `max_retries` at 0 so Faraday does not double the 400. Fall back to `search_context_size` when the desk only needs a smaller context.

Shown in [Sequim search context](features/18-provider-tools-and-citations/02-sequim-search-context/).

### with_citations on OpenAI warns and leaves document citations empty

**What happens.** `chat.with_citations` then `ask(..., with: pdf)` on `gpt-4.1-mini` logs a warning matching `does not support citations` and the model id. The warning is on `RubyLLM.logger`, which is memoized: a later `config.logger =` does not receive it until `@logger` is cleared. `response.citations` is `[]`. The model still reads the PDF: the Protection Island brief contains `240` and `10:46`. The request body has `"type":"input_file"` and `data:application/pdf;base64,`.

**Why it matters.** Turning the flag on does not make OpenAI cite the attached card. A watch that requires `citations.any?` after a PDF ask will fail even when the clerk copied the figures.

**What to do.** Read the content. Use Anthropic, Cohere, or Bedrock Converse when document citations must be filled. Use web search or file search when this catalog needs `Citation` objects on OpenAI. Clear `@logger` after pointing `config.logger` at a StringIO, the same way Smith Island does.

Shown in [Protection Island PDF citations](features/18-provider-tools-and-citations/03-protection-island-pdf-citations/). See also [Smith Island logger](features/09-configuration-and-contexts/06-smith-island-logger/).

### SearchResults becomes JSON; OpenAI does not cite it

**What happens.** A `RubyLLM::Tool` that returns `RubyLLM::SearchResults` writes JSON with a `search_results` key onto the `:tool` message. `SearchResults.from_content` reads those titles back. `response.citations` is still `[]`. `RubyLLM::SearchResults.new` with no hits raises `ArgumentError` matching `at least one result`. The forced Marrowstone request names `kelp_ledge_cabinet` in `tool_choice`.

**Why it matters.** SearchResults is a RAG payload for the next model turn, not an OpenAI citation list. An empty constructor fails in Ruby, before HTTP.

**What to do.** Parse the tool message with `from_content`. Do not expect `response.citations` on this provider. Always pass at least one hit.

Shown in [Marrowstone SearchResults RAG](features/18-provider-tools-and-citations/04-marrowstone-search-results/).

### streamed search puts citations on chunks

**What happens.** A block on `ask` with `:web_search` sends `"stream":true`. Some chunks already carry citations. The completed hail's `citations` has HTTP URLs. When both lists are non-empty they overlap. `server_tool_calls` still includes `web_search_call`.

**Why it matters.** A stream that only reads `chunk.content` never sees the NOAA URL until `ask` returns.

**What to do.** Read citations off the completed message. Copy URLs from a chunk only when that chunk already has them.

Shown in [Admiralty Head streamed citations](features/18-provider-tools-and-citations/05-admiralty-head-streamed-citations/).

### code_execution is code_interpreter; server_tool_use stays nil

**What happens.** `with_provider_tools(:code_execution)` sends `"type":"code_interpreter"` and `"container":{"type":"auto"}`. `server_tool_calls` includes `code_interpreter_call`. `tokens.server_tool_use` is `nil`. Roles stay `[:system, :user, :assistant]`: the interpreter is not a local `:tool` message. The Bush Point brief contains `5.99`.

**Why it matters.** A usage line that copies `web_search_requests` onto every hosted tool will store nothing for code. The run still happened.

**What to do.** Assert `code_interpreter_call` and the printed figure. Treat `server_tool_use` as search-specific on this model.

Shown in [Bush Point code execution](features/18-provider-tools-and-citations/06-bush-point-code-execution/).

### file_search needs vector_store_ids

**What happens.** `with_provider_tools(:file_search)` with no ids raises `RubyLLM::BadRequestError` matching `vector_store_ids`. After `RubyLLM.upload` with `purpose: "user_data"`, a Net::HTTP `POST /v1/vector_stores`, `POST .../files`, and a poll to `completed`, `file_search: { vector_store_ids: [id] }` cites `lagoon-point-card.txt`. `source_id` starts with `file-`. `server_tool_calls` includes `file_search_call`. The store is not a RubyLLM object.

**Why it matters.** The alias alone is not a search. Create-with-`file_ids` can race an empty store; attach-and-poll is what this cassette recorded.

**What to do.** Catch the missing-ids 400, upload as `user_data`, attach, wait for `completed`, then pass `vector_store_ids`. Delete the store in `ensure`.

Shown in [Lagoon Point file search](features/18-provider-tools-and-citations/07-lagoon-point-file-search/).

### hosted mcp remaps name and url

**What happens.** `with_provider_tools(mcp: { name: "learn", url: "https://learn.microsoft.com/api/mcp", require_approval: "never", allowed_tools: ["microsoft_docs_search"] })` sends `"type":"mcp"`, `"server_label":"learn"`, `"server_url":"https://learn.microsoft.com/api/mcp"`, and `"require_approval":"never"`. The request does not contain `"url":"https://learn.microsoft.com/api/mcp"`. `server_tool_calls` includes `mcp_list_tools` and `mcp_call` named `microsoft_docs_search`. Roles stay `[:system, :user, :assistant]`. This is not `RubyLLM::MCP`.

**Why it matters.** A cassette or proxy rule that looks for `url` on the MCP tool will miss the connector. Feature 15 already bottled the first-party client.

**What to do.** Assert `server_label` and `server_url`. Pass `require_approval: "never"` when the hosted tool should run without a pause.

Shown in [Mutiny Bay remote MCP](features/18-provider-tools-and-citations/08-mutiny-bay-remote-mcp/).

### :web_fetch raises before HTTP

**What happens.** `with_provider_tools(:web_fetch)` raises `RubyLLM::UnsupportedServerToolError` matching `:web_fetch`. The message lists Known aliases including `:web_search`, `:file_search`, `:code_execution`, and `:mcp`. It does not list `:web_fetch`. No HTTP call is made for that alias. The Useless Bay cassette has one interaction: the later `:web_search`.

**Why it matters.** `:web_fetch` is a Gemini/OpenRouter name. Copying it onto OpenAI Responses fails in Ruby, before Faraday.

**What to do.** Rescue `UnsupportedServerToolError` and parse Known aliases. Fall back to `:web_search` on this protocol.

Shown in [Useless Bay unknown alias](features/18-provider-tools-and-citations/09-useless-bay-unknown-alias/).

### with_citations(false) does not strip search citations

**What happens.** `with_citations(nil)` raises `ArgumentError` matching `true or false`. `with_citations(false)` sets `chat.citations` to `false`. A following `:web_search` still fills `response.citations` with HTTP URLs and records a `web_search_call`.

**Why it matters.** The flag is a document-citation switch. Search annotations do not read it. Turning it off does not hide NOAA links.

**What to do.** Use the flag only for attached documents. Read search citations off the message either way.

Shown in [Double Bluff citations off](features/18-provider-tools-and-citations/10-double-bluff-citations-off/).

### Agent.chat is a Chat; provider_tools is a class list

**What happens.** `provider_tools :web_search` stores `[{ name: :web_search, options: {} }]` on the class. `WatchClerk.chat(...)` returns a `RubyLLM::Chat`. `WatchClerk.new.ask` sends `"type":"web_search"` with no separate `with_provider_tools`. A second `ask` keeps the earlier hail: roles are `[:system, :user, :assistant, :user, :assistant]`.

**Why it matters.** `Agent.chat` is the unwrapped chat API, the same split as `rescue_from` in feature 14. The macro is enough for the hosted search.

**What to do.** Call `ask` on an agent instance. Read `Agent.provider_tools` for the declared list.

Shown in [Hood Head agent provider tools](features/18-provider-tools-and-citations/11-hood-head-agent-tools/).

### url_citation indexes slice the hail

**What happens.** When OpenAI returns `url_citation` annotations, each `RubyLLM::Citation` has `start_index` and `end_index`. `content[start_index...end_index]` equals `citation.text`. `to_h` includes `:url` and omits nil `:cited_text` and `:start_page`.

**Why it matters.** A footnote that uses `cited_text` or page numbers will be blank on this provider. The span is a byte range into `content`.

**What to do.** Slice with the indexes. Assert `to_h` against the keys that are actually present.

Shown in [Tala Point citation indexes](features/18-provider-tools-and-citations/12-tala-point-citation-indexes/).

### both hosted tools stay on every capstone request

**What happens.** An agent with `provider_tools :web_search, :code_execution` sends both `"type":"web_search"` and `"type":"code_interpreter"` on the first request and again on the second. The hail message has `web_search_call` and citation URLs. The height message has `code_interpreter_call` and `5.99`. `server_tool_calls` stay on their own messages. Declared tools are `[{ name: :web_search, options: {} }, { name: :code_execution, options: {} }]`.

**Why it matters.** Declaring two hosted tools does not send only the one the desk asked for. Input tokens include both specs on every turn.

**What to do.** Read `server_tool_calls` per message. Keep both aliases on the agent when the overnight desk really uses both.

Shown in [Termination Point search desk capstone](features/18-provider-tools-and-citations/13-termination-point-search-desk/).

## Tool approval and loop control

### Forced tool_choice is cleared even while the call still waits on approval

**What happens.** `with_tool_options(choice: PublishWatchNotice)` sends `"tool_choice":{"type":"function","name":"publish_watch_notice"}` on the first Port Ludlow request. `ask` parks because the tool `requires_approval`. `run_tools` has not executed it, but it still clears the forced choice. The follow-up request after `approve` includes the tool result and omits `tool_choice`. The provider reports `"tool_choice":"auto"` on that response.

**Why it matters.** A watch that re-sends the parked chat expecting the same forced latch will not find `tool_choice` on the second POST. The model is free to skip the tool or call it again.

**What to do.** Re-apply `with_tool_options(choice:)` before the next `generate` if the latch still has to be forced. Assert the first request has the flat function object and the follow-up does not contain `tool_choice`.

Shown in [Port Ludlow publish latch](features/19-tool-approval-and-loop-control/01-port-ludlow-publish-latch/).

### A denial is JSON with a fixed error string

**What happens.** `deny` then `complete` appends a `:tool` message whose content is `{"error":"The user denied the fire_range_charge tool call."}`. `execute` never runs. The spoken answer continues from that JSON.

**Why it matters.** A reader looking for a denial role, or for a Ruby exception, will not find one. The model sees the same `{ error: }` shape a tool would return for a miss.

**What to do.** Parse the tool message as JSON and match that error string. Assert the side effect flag is still false.

Shown in [Dabob Bay deny the charge](features/19-tool-approval-and-loop-control/02-dabob-bay-deny-charge/).

### PendingToolCallsError is not a RubyLLM::Error

**What happens.** A second `ask` while `estuary_latch` is still waiting raises `RubyLLM::PendingToolCallsError`. The message names the unanswered tool and tells you to `complete` after `approve` or `deny`. The class inherits `StandardError`. A `rescue RubyLLM::Error` does not catch it. The second question is never staged.

**Why it matters.** The same split as `CancelledError`: provider failures inherit `RubyLLM::Error`, this local refusal does not.

**What to do.** Rescue `PendingToolCallsError` on its own. Finish the pending round before asking again.

Shown in [Skokomish pending ask raises](features/19-tool-approval-and-loop-control/08-skokomish-pending-ask/).

### Concurrent tool results join in completion order, so the cassette body races

**What happens.** `concurrency: :threads` with two Lilliwaup tools appends each `:tool` message as that thread finishes. The next `generate` request includes those results in that order. VCR matches on body. A replay whose creek and boom threads finish in the other order misses the recorded interaction.

**Why it matters.** A live recording that printed the right answer still fails on cassette replay, even though both tools ran.

**What to do.** Give the tools staggered `sleep`s so the same card is always first, on record and on replay. Assert the two `Thread.current.object_id` values differ, not the YAML order of the tool messages.

Shown in [Lilliwaup concurrency threads](features/19-tool-approval-and-loop-control/07-lilliwaup-concurrency-threads/).

### The persisted approval column is the string approved, not true

**What happens.** `approve` on an `acts_as_chat` Seabeck log writes `"approved"` to `ruby_llm_tool_calls.approval`. Before that write the column is `nil`. `HarborMaster.find` then `complete` executes because the approval checker reads that string as `true`. The class-level latch is still unset until that second `complete`.

**Why it matters.** A job that stores `true` in the column, or that compares with `== true`, will not resume. `pending_approvals` on the record returns `RubyLLM::ActiveRecord::ToolCall` rows, not `RubyLLM::ToolCall` objects.

**What to do.** Call `approve` / `deny` and read the string. Load the chat through the agent class so the tools and `requires_approval` come back.

Shown in [Seabeck Rails approval job](features/19-tool-approval-and-loop-control/12-seabeck-rails-approval-job/).

## Running the examples

### A non-ASCII SSE body is stored as YAML !binary

**What happens.** An SSE body that contains U+202F is stored by VCR as YAML `!binary`. A raw read of the file does not contain `data:`. `YAML.load_file` returns the body, and forcing UTF-8 shows the `data:` lines and the narrow space. On the original OpenRouter date-pack recording, one delta ends in `0.4\u202f` and the next begins with `kg`, so the contiguous `0.4\u202fkg` is on the joined speech, not in a single SSE line. An ASCII SSE cassette, such as the well log, keeps the `data:` lines as plain YAML. Neither file contains a live `sk-` token. The placeholder is `<OPENAI_API_KEY>` on the bottled OpenAI recordings.

**Why it matters.** `grep data:` across `cassettes/*.yml` misses the date-pack dictation. A test that scans the YAML text for a packed weight will not see it.

**What to do.** Load the cassette with YAML and force UTF-8 before reading SSE lines. Keep the secret check on the raw bytes.

Shown in [Muscat date-pack dictation](features/02-streaming/01-muscat-date-pack/).

### A second play of one cassette returns the same pieces

**What happens.** Playing the well-log cassette again, with no API key, returns the same pieces and the same speech. The cassette holds one HTTP interaction. Those pieces are the non-empty `delta.content` strings in that SSE body.

**Why it matters.** A catalog run with the key unset is that replay. The test records one interaction, and it compares a second play only when `LIVE` is unset.

**What to do.** Assert the pieces against the stored SSE. Compare a second play only when `LIVE` is unset.

Shown in [Reykjavík geothermal well log](features/02-streaming/02-reykjavik-well-log/).

### MCP JSON-RPC request ids are UUIDs

**What happens.** First-party `RubyLLM::MCP` Streamable HTTP requests send `"id":"<uuid>"`. `HTTP::Stream` finds the answer by that same id. A second play of the Smith Island weather-token cassette, with no API key, still matches those bodies because the player strips the UUID before comparing and copies the live id onto the recorded JSON-RPC result. Without that copy, discover looks unanswered and the client falls back to the `initialize` handshake, which is not in the cassette. The bearer and OAuth placeholders remain `<MCP_BEARER_TOKEN>` and `<MCP_OAUTH_ACCESS_TOKEN>`.

**Why it matters.** Matching on the raw body would fail every replay: `SecureRandom.uuid` is new on each `discover` and `tools/list`. Leaving the recorded result id in place makes the watch miss a 200 it already stored.

**What to do.** Keep `jsonrpc_body` in the cassette player, and rewrite the result id on playback. Do not hand-author a fixed id.

Shown in [Smith Island bearer and OAuth](features/15-mcp-client/08-smith-island-bearer/).

## Provider gotchas

### OpenRouter sends reasoning_details back on the next ask

**What happens.** A first request to `nvidia/nemotron-3-super-120b-a12b:free` has no `reasoning_details`. The response carries a `reasoning` string and a `reasoning_details` array. RubyLLM stores that array on the assistant message and the next request includes it on that message. Confirmed on the retort log, where the second request body contains `reasoning_details` and the first does not, and on the chart correction, where the same replay happens after a turn whose `content` was null.

**Why it matters.** A one-line correction still uploads the previous turn's reasoning. Input tokens grow by that text, not only by the visible reply. An empty `content` is not an empty turn on the wire.

**What to do.** Expect a multi-turn chat on this model to get larger by the reasoning, and keep `max_retries` at 0 when you are recording a fixed number of calls. Do not strip the array yourself if a later turn needs the model to continue; OpenRouter wants it back.

Shown in [Lagos ankara bale log for the morning receiving](features/01-chat-basics/04-lagos-ankara-bale-log/) and [Accession tag for the Singapore Botanic Gardens](features/01-chat-basics/12-singapore-accession-tag/).

### with_max_output_tokens is max_tokens on OpenRouter

**What happens.** The chat that called `with_max_output_tokens(2000)` sent `"max_tokens":2000`. The chat that left the cap unset omitted `max_tokens`. The field is not `max_completion_tokens`. A temperature that was never set is omitted the same way: the unset wind-board request has no `temperature` key, and the chat set to `0.1` sends `"temperature":0.1`.

**Why it matters.** A cassette or a proxy rule that looks for `max_completion_tokens` will not see the cap. A test that assumes every request has a temperature will not match the unset chat.

**What to do.** Assert the chat readers (`temperature`, `max_output_tokens`) and, when the wire shape matters, the keys actually present in the cassette body.

Shown in [Brussels chocolate tempering board](features/01-chat-basics/10-brussels-tempering-board/).

### This free model puts U+202F beside a number

**What happens.** Replies from `nvidia/nemotron-3-super-120b-a12b:free` often separate a word and a numeral with U+202F (narrow no-break space), as in `rack\u202f3` and `242\u202f°C`. The same character shows up between a numeral and a unit. The original OpenRouter Muscat date-pack dictation contains `0.4\u202fkg` and `8.1\u202fkg`. A Ruby regexp `\s` does not match that character. `[[:space:]]` and `\p{Space}` do. It is not on every number: the Sheffield heat-lot stream wrote `Rack 3` with a normal space.

**Why it matters.** `assert_includes reply, "rack 3"` and `/0\.4\skg/` fail on a reply that a person would read as "rack 3" or "0.4 kg".

**What to do.** Match the recorded character, or use `[[:space:]]`, when the assertion is about a word or a unit sitting next to a number.

Shown in [Lagos ankara bale log for the morning receiving](features/01-chat-basics/04-lagos-ankara-bale-log/) and [Muscat date-pack dictation](features/02-streaming/01-muscat-date-pack/).
