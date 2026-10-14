# Chat basics · 05 · Friday Harbor berth assignment

The night harbormaster at the Port of Friday Harbor has four lines on the berth board and one boat that needs a berth. The reply names Alden's berth. The user message on the chat still holds Retort, the seiner, and the closed berth.

**What it teaches**

- `ask` returns the assignment. The reply's job is to name G-14.
- `chat.messages` is the transcript. The user turn still contains H-2, the fuel float, and J-7.
- Reading `role` and `content` off each message is how you inspect that transcript. Nothing is copied into a side list.

**Files**

| File | Role |
| --- | --- |
| [`slip_assignment.rb`](slip_assignment.rb) | Asks where Alden goes and reads `chat.messages` |
| [`slip_assignment_test.rb`](slip_assignment_test.rb) | Replays the cassette and checks the assignment and the board |
| [`cassettes/slip_assignment.yml`](cassettes/slip_assignment.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/05-friday-harbor-berth-assignment/slip_assignment.rb
bundle exec ruby features/01-chat-basics/05-friday-harbor-berth-assignment/slip_assignment_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Alden is assigned to G-14. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/05-friday-harbor-berth-assignment/slip_assignment.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
