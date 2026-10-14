# Multimodal attachments · 07 · Ediz Hook buoy check-in

Alden checks in from the buoy tender at Ediz Hook. The watch logs the
clock time and the battery voltage, then asks only for the voltage.
The second `ask` attaches nothing.

**What it teaches**

- A follow-up with no `with:` still describes the earlier recording.
- The first user message keeps one attachment. The second user message
  has an empty attachment list.
- Both request bodies contain one `input_audio` part. The second body
  is larger because it also carries the first answer.

The MP3 is stored twice, as base64. That is the bulk of this cassette.

**Files**

| File | Role |
| --- | --- |
| [`buoy_check_in.rb`](buoy_check_in.rb) | Logs the check-in, then asks for the voltage |
| [`buoy_check_in_test.rb`](buoy_check_in_test.rb) | Replays the cassette and checks both audio parts |
| [`buoy-check-in.mp3`](buoy-check-in.mp3) | The check-in |
| [`cassettes/buoy_check_in.yml`](cassettes/buoy_check_in.yml) | The two Chat Completions round-trips |

**Sample file**

`buoy-check-in.mp3` is speech synthesized for this catalog with espeak-ng,
then encoded with ffmpeg at 16 kHz. The words are original.

**Try it**

```sh
bundle exec ruby features/05-multimodal-attachments/07-ediz-hook-buoy-check-in/buoy_check_in.rb
bundle exec ruby features/05-multimodal-attachments/07-ediz-hook-buoy-check-in/buoy_check_in_test.rb
```

Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/05-multimodal-attachments/07-ediz-hook-buoy-check-in/buoy_check_in.rb
```

**Model**

`gpt-audio-mini` on OpenAI. Preferred free slug when the daily cap allows
it: `thinkingmachines/inkling:free`.
