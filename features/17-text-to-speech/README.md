# Text to speech

`RubyLLM.speak` returns a `RubyLLM::Speech`. Read `model`, `voice`, `format`, `mime_type`, `to_blob`. `save` writes the file. A block yields `SpeechChunk` objects (`data`, `format`, `mime_type`) before the complete recording. Pass `model:`, `voice:`, `format:`, and `provider_options:` (OpenAI `instructions`/`speed`, ElevenLabs `voice_settings`).

Official reference: [Text to Speech](https://rubyllm.com/text-to-speech/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.speak("Welcome.").save("welcome.mp3")`
- `speech.model`, `voice`, `format`, `mime_type`, `to_blob`
- streaming block yielding `SpeechChunk`
- `model:`, `voice:`, `format:`
- `provider_options:` for style and speed
- `default_speech_model`

## Providers that can record it

OpenAI (`gpt-4o-mini-tts` and related). Gemini TTS (`gemini-*-tts-preview`, PCM). ElevenLabs (`eleven_flash_v2_5`, voice ids). Deepgram Aura (`aura-2-*-en`). xAI, Mistral, Bedrock (limited). This catalog's cheap record path is OpenAI's default TTS voice. ElevenLabs and Gemini need their own keys. No `:free` OpenRouter TTS slug was listed for this bottle.

## Examples (0 of 13 bottled)

01. Fort Worden welcome hail — planned
02. Hadlock slip announcement voice — planned
03. Irondale WAV format — planned
04. Chimacum streamed chunks — planned
05. Oak Bay nova vs alloy — planned
06. Kinney Point Gemini PCM — planned
07. Cape George ElevenLabs voice id — planned
08. Kala Point speed instructions — planned
09. Fort Flagler language_code — planned
10. Rat Island mime_type — planned
11. McCurdy Point save vs to_blob — planned
12. Middle Point Active Storage blob — planned
13. Beckett Point radio hail capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
