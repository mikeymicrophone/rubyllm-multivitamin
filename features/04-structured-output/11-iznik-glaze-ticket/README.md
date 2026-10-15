# Structured output · 11 · Iznik glaze ticket

A handwritten glaze ticket at the Iznik tile workshop contradicts itself. Cobalt is crossed out. Osman is crossed out. The field descriptions tell the model to keep Çini 4, Iznik red, 14.5 bowls, and Hatice. A Decisions predicate then says the kiln needs the firing before Friday.

**What it teaches**

- Descriptions are on the schema the model sees. The glaze description says to ignore a colour that was crossed out.
- The parsed ticket keeps Iznik red and Hatice.
- `probability` on a Judge is sent as `type: predicate`. The answer is a probability from 0 to 1. This ticket is at least `0.9`.

**Files**

| File | Role |
| --- | --- |
| [`glaze_ticket.rb`](glaze_ticket.rb) | Schema on `gpt-4.1-mini`, then the predicate on `gpt-6-luna` |
| [`glaze_ticket_test.rb`](glaze_ticket_test.rb) | Replays the cassette |
| [`cassettes/glaze_ticket.yml`](cassettes/glaze_ticket.yml) | Live recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/11-iznik-glaze-ticket/glaze_ticket_test.rb
```

Re-record. The predicate always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/11-iznik-glaze-ticket/glaze_ticket_test.rb
```

**Model**

The ticket is `gpt-4.1-mini`. The Friday predicate is `gpt-6-luna`.
