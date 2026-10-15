# Structured output · 07 · Lima trolleybus shoe ticket

The shoe fitter logs Trolebús 12 on Avenida Arequipa. Voltage is required. The replacement date is optional and the ticket has none. The pencil note is optional and the ticket has one.

**What it teaches**

- `required: false` leaves a property out of `required`.
- OpenAI strict mode turns off. This request sends `strict: false`.
- The parsed Hash includes `pencil_note` and omits `replaced_on`.

**Files**

| File | Role |
| --- | --- |
| [`shoe_ticket.rb`](shoe_ticket.rb) | Asks for the service ticket |
| [`shoe_ticket_test.rb`](shoe_ticket_test.rb) | Replays the cassette |
| [`cassettes/shoe_ticket.yml`](cassettes/shoe_ticket.yml) | Live recording of the schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/07-lima-trolleybus-shoe/shoe_ticket_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/07-lima-trolleybus-shoe/shoe_ticket_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
