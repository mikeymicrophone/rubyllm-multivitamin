# Evaluations · 04 · Toledo damascene-wire tool

The wire clerk at the Toledo damascene yard reads bed TD-South through
`posted_damascene_card`, then files 14 wires for cart Inés. The grader sees
the spoken answer.

**What it teaches**

- `perform` may force a tool so the conversation holds a tool turn.
- The grader still grades the spoken answer against `expected_output`.
- Tool messages sit on the returned conversation.

**Files**

| File | Role |
| --- | --- |
| [`damascene_wire.rb`](damascene_wire.rb) | Forces the wire-card tool, then grades the count |
| [`damascene_wire.yml`](damascene_wire.yml) | The wire-count case |
| [`damascene_wire_test.rb`](damascene_wire_test.rb) | Replays the cassette and checks the tool round |
| [`cassettes/damascene_wire.yml`](cassettes/damascene_wire.yml) | Tool call, spoken answer, and grader |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/04-toledo-damascene-wire/damascene_wire.rb
bundle exec ruby features/20-evaluations/04-toledo-damascene-wire/damascene_wire_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/04-toledo-damascene-wire/damascene_wire.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
