# Structured output · 11 · Port Angeles net ticket

A handwritten mending ticket at the Port Angeles net loft contradicts itself. Cotton is crossed out. Retort is crossed out. The field descriptions tell the model to keep F/V Kulshan, No. 18 tarred nylon, 14.5 fathoms, and Alden. A Decisions predicate then says the loft needs the net before Friday.

**What it teaches**

- Descriptions are on the schema the model sees. The twine description says to ignore a fiber that was crossed out.
- The parsed ticket keeps tarred nylon and Alden.
- `probability` on a Judge is sent as `type: predicate`. The answer is a probability from 0 to 1. This ticket is at least `0.9`.

**Files**

| File | Role |
| --- | --- |
| [`mending_ticket.rb`](mending_ticket.rb) | Schema on `gpt-4.1-mini`, then the predicate on `gpt-6-luna` |
| [`mending_ticket_test.rb`](mending_ticket_test.rb) | Replays the cassette |
| [`cassettes/mending_ticket.yml`](cassettes/mending_ticket.yml) | Live OpenAI recording of both calls |

**Try it**

```sh
bundle exec ruby features/04-structured-output/11-port-angeles-net-ticket/mending_ticket_test.rb
```

Re-record. The predicate always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/11-port-angeles-net-ticket/mending_ticket_test.rb
```

**Model**

The ticket is `gpt-4.1-mini`. The Friday predicate is `gpt-6-luna`.
