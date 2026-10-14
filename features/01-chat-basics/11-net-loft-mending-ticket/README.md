# Chat basics · 11 · Net loft mending ticket

Ticket NL-214 for the seiner Cape Flattery is on the bench at the Anacortes net loft. Hattie, the loft boss, works it on one chat. Calder, the skipper, asks about the same ticket on another chat, with different instructions. Only Hattie's chat hears that the belly tear grew.

**What it teaches**

- `with_instructions` is the persona. Two chats, two instruction strings, two voices.
- Hattie's transcript grows turn by turn. After the ticket the chat has three messages. After the hail it has five: system, user, assistant, user, assistant.
- Calder's chat never receives the "9 meshes" hail. A persona is not a shared transcript.

**Files**

| File | Role |
| --- | --- |
| [`mending_ticket.rb`](mending_ticket.rb) | Runs Hattie's two turns and Calder's one ask |
| [`mending_ticket_test.rb`](mending_ticket_test.rb) | Replays the cassette and checks the personas and the lengths |
| [`cassettes/mending_ticket.yml`](cassettes/mending_ticket.yml) | The three Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/11-net-loft-mending-ticket/mending_ticket.rb
bundle exec ruby features/01-chat-basics/11-net-loft-mending-ticket/mending_ticket_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Hattie starts with cork-line twine 36. After the hail the belly is twine 48 at 9 meshes, and the cork line is still 36. Calder only has the original ticket. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/11-net-loft-mending-ticket/mending_ticket.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
