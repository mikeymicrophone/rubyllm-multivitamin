# Multimodal attachments · 03 · Cape Disappointment foghorn call

Alden phones the foghorn timing at Cape Disappointment. The clerk logs
the station, the blast count, and the visibility from the recording.

**What it teaches**

- `ask` takes one audio file with `with:`.
- The model is `gpt-audio-mini`, because `gpt-4.1-mini` on the Responses
  API cannot send audio.
- The user message keeps an `Attachment` whose type is `:audio`.
- `cost.total` is nil. Token counts are present, including `audio_tokens`
  on the provider usage object.

**Files**

| File | Role |
| --- | --- |
| [`foghorn_call.rb`](foghorn_call.rb) | Asks the audio model what the tender reported |
| [`foghorn_call_test.rb`](foghorn_call_test.rb) | Replays the cassette and checks the log line and the audio part |
| [`foghorn-call.mp3`](foghorn-call.mp3) | The timing call |
| [`cassettes/foghorn_call.yml`](cassettes/foghorn_call.yml) | The Chat Completions round-trip |

**Sample file**

`foghorn-call.mp3` is speech synthesized for this catalog with espeak-ng,
then encoded with ffmpeg at 16 kHz. The words are original. The cassette
stores the MP3 as base64 in `input_audio.data`, so this file is larger
than the text cassettes elsewhere in the catalog.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/03-cape-disappointment-foghorn-call/foghorn_call.rb
bundle exec ruby features/05-multimodal-attachments/03-cape-disappointment-foghorn-call/foghorn_call_test.rb
```

The cassette is a live recording of `gpt-audio-mini`. The free OpenRouter
audio slug was past its daily cap. Re-record it with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/03-cape-disappointment-foghorn-call/foghorn_call.rb
```

**Model**

`gpt-audio-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `thinkingmachines/inkling:free`.
