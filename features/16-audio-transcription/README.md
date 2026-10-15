# Audio transcription

`RubyLLM.transcribe` turns a recording into a `RubyLLM::Transcription`. Read
`text`, `duration`, `segments`, and `words`. Pass `language:`, `prompt:`,
`timestamps:`, `format:`, `speaker_names:`, and `speaker_references:`. A
block streams `TranscriptionChunk` objects (`delta?`, `partial?`,
`segment?`, `done?`). `ctx.transcribe` uses a context's
`default_transcription_model`. Silent audio returns empty `text`. A
transcript is ordinary text for a later `chat.ask`.

Official reference: [Audio Transcription](https://rubyllm.com/audio-transcription/).

## Models

These cassettes were recorded on OpenAI with `LIVE=1 LIVE_PROVIDER=openai`.
`gpt-transcribe` is RubyLLM 2.1.1's default. `whisper-1` is the model that
takes `timestamps:` and `format: "srt"`. `gpt-4o-transcribe-diarize` labels
speakers. Slots 12 and 13 then chat with `gpt-4.1-mini`.
`LIVE_PROVIDER` does not retarget the transcription slugs.

## Examples (13 of 13 bottled)

01. [Tatoosh foghorn tape](01-tatoosh-foghorn-tape/) — available
02. [Clallam Bay radio check](02-clallam-bay-radio-check/) — available
03. [Sekiu Spanish hail](03-sekiu-spanish-hail/) — available
04. [Freshwater Bay vocabulary prompt](04-freshwater-bay-vocabulary/) — available
05. [Morse Creek word timestamps](05-morse-creek-timestamps/) — available
06. [Dungeness Spit SRT card](06-dungeness-spit-srt/) — available
07. [Mystery Bay streamed deltas](07-mystery-bay-stream/) — available
08. [Kilisut Harbor diarized watch](08-kilisut-harbor-diarize/) — available
09. [Indian Island known-speaker clips](09-indian-island-speakers/) — available
10. [Mats Mats silent tape](10-mats-mats-silence/) — available
11. [Shine Tidal tokens](11-shine-tidal-tokens/) — available
12. [Thorndyke watch brief](12-thorndyke-watch-brief/) — available
13. [Squamish Harbor watch tape capstone](13-squamish-harbor-capstone/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `RubyLLM.transcribe` returns a `Transcription`; `gpt-transcribe` |
| 02 | `ctx.transcribe` uses the context's `whisper-1` default |
| 03 | `language: "es"` on the request; Spanish hail from Sekiu |
| 04 | `prompt:` sends Dungeness, kelp ledge, MLLW, Fresnel |
| 05 | `timestamps: [:word, :segment]` fills `words` and `segments` |
| 06 | `format: "srt"`; `text` is the subtitle card |
| 07 | A block yields `TranscriptionChunk`; joined deltas equal `text` |
| 08 | `gpt-4o-transcribe-diarize` labels speakers on segments |
| 09 | `speaker_names:` and `speaker_references:` for Alden and Calder |
| 10 | A silent reel is HTTP 200 and empty `text` |
| 11 | `gpt-transcribe` reports duration seconds; token counts are nil |
| 12 | Pipe `tape.text` into `chat.ask` for the posted brief |
| 13 | Capstone: prompt, timestamps, then the posted card |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
