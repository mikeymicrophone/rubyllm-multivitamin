# Structured output · 07 · Ediz Hook buoy ticket

The buoy tender logs the Ediz Hook bell battery. Voltage is required. The replacement date is optional and the ticket has none. The pencil note is optional and the ticket has one.

**What it teaches**

- `required: false` leaves a property out of `required`.
- OpenAI strict mode turns off. This request sends `strict: false`.
- The parsed Hash includes `pencil_note` and omits `replaced_on`.

**Files**

| File | Role |
| --- | --- |
| [`buoy_ticket.rb`](buoy_ticket.rb) | Asks for the service ticket |
| [`buoy_ticket_test.rb`](buoy_ticket_test.rb) | Replays the cassette |
| [`cassettes/buoy_ticket.yml`](cassettes/buoy_ticket.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/07-ediz-hook-buoy-ticket/buoy_ticket_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/07-ediz-hook-buoy-ticket/buoy_ticket_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
