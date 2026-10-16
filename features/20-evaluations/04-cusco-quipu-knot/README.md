# Evaluations · 04 · Cusco quipu-knot tool

The quipu clerk at Qorikancha reads bed QK-South through `posted_quipu_card`,
then files 14 cords for cart Inti. The grader sees the spoken answer.

**What it teaches**

- `perform` may force a tool so the conversation holds a tool turn.
- The grader still grades the spoken answer against `expected_output`.
- Tool messages sit on the returned conversation.

**Files**

| File | Role |
| --- | --- |
| [`quipu_knot.rb`](quipu_knot.rb) | Forces the cord-card tool, then grades the count |
| [`quipu_knot.yml`](quipu_knot.yml) | The cord-count case |
| [`quipu_knot_test.rb`](quipu_knot_test.rb) | Replays the cassette and checks the tool round |
| [`cassettes/quipu_knot.yml`](cassettes/quipu_knot.yml) | Tool call, spoken answer, and grader |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/04-cusco-quipu-knot/quipu_knot.rb
bundle exec ruby features/20-evaluations/04-cusco-quipu-knot/quipu_knot_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/04-cusco-quipu-knot/quipu_knot.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
