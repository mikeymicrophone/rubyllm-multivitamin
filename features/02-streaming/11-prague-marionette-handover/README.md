# Streaming · 11 · Prague marionette handover

The outgoing stage manager at the National Marionette Theatre in Prague
speaks the morning call board and the house PA card, then answers the
relief's question about the fly loft. Both answers are streamed on one
chat. The second request includes the first answer.

**What it teaches**

- Two `ask` calls with blocks share `chat.messages`.
- Each answer's joined chunks equal that returned message.
- The second request body contains the first assistant turn as `output_text`
  inside `input`. This recording has no `reasoning_details`.
- The follow-up's input token count is larger because that turn is sent again.

**Files**

| File | Role |
| --- | --- |
| [`marionette_handover.rb`](marionette_handover.rb) | Streams the brief, then the loft answer |
| [`marionette_handover_test.rb`](marionette_handover_test.rb) | Replays both and checks the second request |
| [`cassettes/marionette_handover.yml`](cassettes/marionette_handover.yml) | The two streamed turns |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/11-prague-marionette-handover/marionette_handover.rb
bundle exec ruby features/02-streaming/11-prague-marionette-handover/marionette_handover_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/02-streaming/11-prague-marionette-handover/marionette_handover_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
