# Error handling · 13 · Willemstad curaçao peel

The steeping desk at Landhuis Chobolobo, Willemstad, first posts a
broken `PeelLot` schema. OpenAI answers 400. The clerk logs
`request_shape.to_h` — no C-4, no Marisol — and asks again without the
schema. The prose brief still puts Marisol in C-4.

**What it teaches**

- Rescue `RubyLLM::Error`, log `request_shape.to_h`, and continue.
- The logged hash has the same keys every time and holds no board text.
- A second chat, without `with_schema`, still briefs the lot.
- The cassette is one 400 and one 200.

**Files**

| File | Role |
| --- | --- |
| [`peel_desk.rb`](peel_desk.rb) | Posts the broken schema, then the prose brief |
| [`peel_desk_test.rb`](peel_desk_test.rb) | Checks the shape, the scrub, and Marisol in C-4 |
| [`cassettes/peel_desk.yml`](cassettes/peel_desk.yml) | The refused schema call and the prose brief |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/13-willemstad-curacao-peel/peel_desk.rb
bundle exec ruby features/13-error-handling/13-willemstad-curacao-peel/peel_desk_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/13-willemstad-curacao-peel/peel_desk.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
