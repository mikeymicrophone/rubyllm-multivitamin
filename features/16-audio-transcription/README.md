# Audio transcription

`RubyLLM.transcribe` turns a recording into a `RubyLLM::Transcription`. Read `text`, `duration`, `segments`, and `words`. Pass `language:`, `prompt:`, `timestamps:`, `format:`, `speaker_names:`, and `speaker_references:`. A block streams `TranscriptionChunk` objects (`delta?`, `partial?`, `segment?`, `done?`). Gemini can raise `ContentFilterError` on a blocked recording.

Official reference: [Audio Transcription](https://rubyllm.com/audio-transcription/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.transcribe("meeting.wav")`
- `transcription.text`, `segments`, `words`, `duration`
- `language:`, `prompt:`, `timestamps:`, `format:`
- `speaker_names:` and `speaker_references:`
- streaming block yielding `TranscriptionChunk`
- `default_transcription_model`

## Providers that can record it

OpenAI (`whisper-1`, `gpt-4o-transcribe`, `gpt-4o-transcribe-diarize`, `gpt-audio-mini` for chat-side audio). OpenRouter hosts some transcription slugs. Gemini / Vertex AI (`gemini-3.5-transcribe`, Live WebSocket). Deepgram, ElevenLabs Scribe (`scribe_v2`, `scribe_v2_realtime`), xAI `grok-stt`, Mistral, Bedrock. This catalog's cheap record path is OpenAI `whisper-1` or `gpt-4o-transcribe`. Free OpenRouter audio slugs move; check the models API the day you record.

## Examples (0 of 13 bottled)

01. Tatoosh foghorn tape — planned
02. Clallam Bay radio check speakers — planned
03. Sekiu Spanish hail (`language:`) — planned
04. Freshwater Bay vocabulary prompt — planned
05. Morse Creek word timestamps — planned
06. Dungeness Spit SRT card — planned
07. Mystery Bay streamed deltas — planned
08. Kilisut Harbor diarized watch — planned
09. Indian Island known-speaker clips — planned
10. Mats Mats blocked Gemini tape — planned
11. Shine Tidal WAV vs MP3 — planned
12. Thorndyke long recording timeout — planned
13. Squamish Harbor watch tape capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
