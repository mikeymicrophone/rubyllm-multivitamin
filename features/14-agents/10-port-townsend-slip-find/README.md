# Agents · 10 · Port Townsend slip find

The slip clerk at Port Townsend posts the 28-knot gust, then the relief
loads that same chat with `find` and asks whether the Kalakala still holds.
`create!` persisted the board. `find` applies the agent at runtime and does
not write a second system row.

**What it teaches**

- `SlipClerk.create!` persists the chat and the first brief.
- `SlipClerk.find(id)` returns the same `SlipChat` row.
- `find` applies instructions at runtime only. The system count stays 1.
- The follow-up still sees the 28-knot gust from the saved turns.

**Files**

| File | Role |
| --- | --- |
| [`slip_find.rb`](slip_find.rb) | Creates the slip, finds it, and asks the holding question |
| [`slip_find_test.rb`](slip_find_test.rb) | Checks the id, the system count, and the gust |
| [`cassettes/slip_find.yml`](cassettes/slip_find.yml) | The two wind-board round-trips |

**Try it**

```sh
bundle exec ruby features/14-agents/10-port-townsend-slip-find/slip_find.rb
bundle exec ruby features/14-agents/10-port-townsend-slip-find/slip_find_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Fallback: OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free`. Checked 15 October 2026.
