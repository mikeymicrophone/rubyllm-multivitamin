# Error handling · 13 · Restoration Point error desk

The ferry-slip desk at Restoration Point, on the south end of Bainbridge
Island, first posts a broken `SlipBerth` schema. OpenAI answers 400.
The clerk logs `request_shape.to_h` — no G-4, no Alden — and asks
again without the schema. The prose brief still puts Alden in G-4.

**What it teaches**

- Rescue `RubyLLM::Error`, log `request_shape.to_h`, and continue.
- The logged hash has the same keys every time and holds no board text.
- A second chat, without `with_schema`, still briefs the slip.
- The cassette is one 400 and one 200.

**Files**

| File | Role |
| --- | --- |
| [`error_desk.rb`](error_desk.rb) | Posts the broken schema, then the prose brief |
| [`error_desk_test.rb`](error_desk_test.rb) | Checks the shape, the scrub, and Alden in G-4 |
| [`cassettes/error_desk.yml`](cassettes/error_desk.yml) | The refused schema call and the prose brief |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/13-restoration-point-error-desk/error_desk.rb
bundle exec ruby features/13-error-handling/13-restoration-point-error-desk/error_desk_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/13-restoration-point-error-desk/error_desk.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 15 October 2026.
