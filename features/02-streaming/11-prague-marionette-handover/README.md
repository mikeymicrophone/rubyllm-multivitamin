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

The cassette is a live recording of OpenAI `gpt-4.1-mini`.
Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/11-prague-marionette-handover/marionette_handover_test.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-` token before the file is written. `LIVE_PROVIDER=openrouter` records
the free slug instead.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
