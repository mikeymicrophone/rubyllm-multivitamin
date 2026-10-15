# Multimodal attachments · 07 · Penang cable check-in

Mei Lin checks in from the Penang landing station. The clerk logs the
time and the voltage from the recording, then asks the voltage again
without attaching the file.

**What it teaches**

- A follow-up `ask` with no new file still sends the earlier recording.
- The first user message keeps the attachment. The second user message
  has none. Both request bodies still contain `input_audio`.
- Follow-up input tokens are at least as large as the first turn.

**Files**

| File | Role |
| --- | --- |
| [`cable_check_in.rb`](cable_check_in.rb) | Logs the check-in, then asks the voltage |
| [`cable_check_in_test.rb`](cable_check_in_test.rb) | Replays both turns and checks the audio is resent |
| [`cable-check-in.mp3`](cable-check-in.mp3) | Mei Lin's call |
| [`cassettes/cable_check_in.yml`](cassettes/cable_check_in.yml) | Two Chat Completions round-trips |

**Sample file**

`cable-check-in.mp3` is speech synthesized for this catalog with espeak-ng,
then encoded with ffmpeg at 16 kHz. The words are original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/07-penang-cable-check-in/cable_check_in.rb
bundle exec ruby features/05-multimodal-attachments/07-penang-cable-check-in/cable_check_in_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/07-penang-cable-check-in/cable_check_in.rb
```

**Model**

`gpt-audio-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `thinkingmachines/inkling:free`.
