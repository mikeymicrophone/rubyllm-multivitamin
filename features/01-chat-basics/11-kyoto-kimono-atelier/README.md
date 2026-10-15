# Chat basics · 11 · Kyoto kimono atelier ticket

Ticket KM-214 for Aiko's iro-tomesode is on the bench at a Shinmonzen-dori atelier in Kyoto. Hanae, the dresser, works it on one chat. Aiko, the bride, asks about the same ticket on another chat, with different instructions. Only Hanae's chat hears that the hem grew.

**What it teaches**

- `with_instructions` is the persona. Two chats, two instruction strings, two voices.
- Hanae's transcript grows turn by turn. After the ticket the chat has three messages. After the hail it has five: system, user, assistant, user, assistant.
- Aiko's chat never receives the "9 cm" hail. A persona is not a shared transcript.

**Files**

| File | Role |
| --- | --- |
| [`kimono_ticket.rb`](kimono_ticket.rb) | Runs Hanae's two turns and Aiko's one ask |
| [`kimono_ticket_test.rb`](kimono_ticket_test.rb) | Replays the cassette and checks the personas and the lengths |
| [`cassettes/kimono_ticket.yml`](cassettes/kimono_ticket.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/11-kyoto-kimono-atelier/kimono_ticket.rb
bundle exec ruby features/01-chat-basics/11-kyoto-kimono-atelier/kimono_ticket_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. Hanae starts with collar silk 36. After the hail the hem is silk 48 at 9 cm, and the collar is still 36. Aiko only has the original ticket. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/11-kyoto-kimono-atelier/kimono_ticket.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
