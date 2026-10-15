# Chat basics · 05 · Dakar Biennale booth assignment

The night registrar at the Dakar Biennale has four lines on the hanging board and one artist that needs a booth. The reply names Chioma's booth. The user message on the chat still holds Mateo, the video artist, and the closed bay.

**What it teaches**

- `ask` returns the assignment. The reply's job is to name G-14.
- `chat.messages` is the transcript. The user turn still contains H-2, the loading dock, and J-7.
- Reading `role` and `content` off each message is how you inspect that transcript. Nothing is copied into a side list.

**Files**

| File | Role |
| --- | --- |
| [`booth_assignment.rb`](booth_assignment.rb) | Asks where Chioma goes and reads `chat.messages` |
| [`booth_assignment_test.rb`](booth_assignment_test.rb) | Replays the cassette and checks the assignment and the board |
| [`cassettes/booth_assignment.yml`](cassettes/booth_assignment.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/05-dakar-biennale-booth/booth_assignment.rb
bundle exec ruby features/01-chat-basics/05-dakar-biennale-booth/booth_assignment_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Chioma is assigned to G-14. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/05-dakar-biennale-booth/booth_assignment.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
