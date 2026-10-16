# Moderation · 10 · Arusha booking desk

The booking clerk in Arusha screens the morning hail, then asks the chat
only if it is clean. The lodge card names Asha and 07:15. Omni-moderation
lets it through. `gpt-4.1-mini` briefs the departure.

**What it teaches**

- Screen the hail before `chat.ask`.
- A clean card reaches the chat. A flagged card would stop here.
- The cassette is one Moderations POST and one Responses POST.

**Files**

| File | Role |
| --- | --- |
| [`booking_desk.rb`](booking_desk.rb) | Screens, then asks |
| [`booking_desk_test.rb`](booking_desk_test.rb) | Checks the brief and the two calls |
| [`cassettes/booking_desk.yml`](cassettes/booking_desk.yml) | Moderations then Responses |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/10-arusha-booking-desk/booking_desk.rb
bundle exec ruby features/23-moderation/10-arusha-booking-desk/booking_desk_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/10-arusha-booking-desk/booking_desk.rb
```

**Model**

`omni-moderation-latest` then `gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
