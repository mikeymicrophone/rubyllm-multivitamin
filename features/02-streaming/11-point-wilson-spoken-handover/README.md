# Streaming · 11 · Point Wilson spoken handover

The outgoing watch at Point Wilson speaks the night tide board and the
foghorn card, then answers the relief's question about the lens cabinet.
Both answers are streamed on one chat. The second request includes the
first answer.

**What it teaches**

- Two `ask` calls with blocks share `chat.messages`.
- Each answer's joined chunks equal that returned message.
- The second request body contains the first assistant turn. On this free
  model it also contains `reasoning_details`, which the first request did
  not send.
- The follow-up's input token count is larger because that turn is sent again.

**Files**

| File | Role |
| --- | --- |
| [`spoken_handover.rb`](spoken_handover.rb) | Streams the brief, then the cabinet answer |
| [`spoken_handover_test.rb`](spoken_handover_test.rb) | Replays both and checks the second request |
| [`cassettes/spoken_handover.yml`](cassettes/spoken_handover.yml) | The two streamed turns |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/11-point-wilson-spoken-handover/spoken_handover.rb
bundle exec ruby features/02-streaming/11-point-wilson-spoken-handover/spoken_handover_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/11-point-wilson-spoken-handover/spoken_handover_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
