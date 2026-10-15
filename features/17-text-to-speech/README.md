# Text to speech

`RubyLLM.speak` returns a `RubyLLM::Speech`. Read `model`, `voice`,
`format`, `mime_type`, `to_blob`. `save` writes the file. A block yields
`SpeechChunk` objects (`data`, `format`, `mime_type`) before the complete
recording. `ctx.speak` uses a context's `default_speech_model`. Pass
`model:`, `voice:`, `format:`, and `provider_options:` (OpenAI
`instructions` and `speed`).

These thirteen cassettes were recorded on OpenAI `tts-1` with
`LIVE=1 LIVE_PROVIDER=openai`. That was the cheapest speech model on
`https://api.openai.com/v1/models` on 15 October 2026. `tts-1-hd` is
twice the character price. `gpt-4o-mini-tts` is the gem default and is
token-priced. There is no `:free` OpenRouter TTS slug. Clips are one
short sentence. The cassette helper replaces large audio bodies with a
short silent MP3 or WAV.

Official reference: [Text to Speech](https://rubyllm.com/text-to-speech/).

## Models

Recorded on `tts-1` with `provider: :openai`. Slots 07 and 13 also chat
with `gpt-4.1-mini`. Slot 06 sets `default_speech_model` on a context and
calls `ctx.speak` without `model:`.

`LIVE=1 LIVE_PROVIDER=openai` records OpenAI again. `LIVE_PROVIDER` does
not retarget speech. Replay ignores `LIVE_PROVIDER`.

## Examples (13 of 13 bottled)

01. [Fort Worden welcome hail](01-fort-worden-welcome-hail/) — available
02. [Hadlock slip announcement voice](02-hadlock-slip-announcement-voice/) — available
03. [Irondale WAV format](03-irondale-wav-format/) — available
04. [Chimacum streamed chunks](04-chimacum-streamed-chunks/) — available
05. [Oak Bay nova vs alloy](05-oak-bay-nova-vs-alloy/) — available
06. [Kinney Point context speak](06-kinney-point-context-speak/) — available
07. [Cape George spoken chat answer](07-cape-george-spoken-answer/) — available
08. [Kala Point speed instructions](08-kala-point-speed-instructions/) — available
09. [Fort Flagler tokens and cost](09-fort-flagler-tokens-cost/) — available
10. [Rat Island mime_type](10-rat-island-mime-type/) — available
11. [McCurdy Point save vs to_blob](11-mccurdy-point-save-blob/) — available
12. [Middle Point refused format](12-middle-point-refused-format/) — available
13. [Beckett Point radio hail capstone](13-beckett-point-radio-hail/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `RubyLLM.speak` returns a `Speech`; default voice alloy, format mp3 |
| 02 | `voice: "nova"` is on the request; `Speech#voice` is nova |
| 03 | `format: "wav"`; `save` writes RIFF bytes |
| 04 | A block yields `SpeechChunk`; joined bytes equal `to_blob` |
| 05 | nova then alloy; both ids stay on `tts-1` |
| 06 | `ctx.speak` uses the context default; global default is unchanged |
| 07 | `chat.ask` then `speak` of `answer.content` |
| 08 | `provider_options:` `instructions` and `speed: 0.85` |
| 09 | `tokens.input` and `cost.total` are nil on raw audio |
| 10 | `mime_type` is `audio/mpeg` then `audio/wav` |
| 11 | `to_blob` equals the bytes `save` wrote |
| 12 | `format: "aiff"` raises `BadRequestError`; cassette is HTTP 400 |
| 13 | Capstone: ask, speak, `save` the radio card |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
