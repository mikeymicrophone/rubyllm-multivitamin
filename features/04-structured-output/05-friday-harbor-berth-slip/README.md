# Structured output · 05 · Friday Harbor berth slip

The berth clerk assigns slip 7 to F/V Kulshan from a raw JSON Schema hash. No Schematist class is involved, and the schema has no name.

**What it teaches**

- `with_schema` accepts a Hash of JSON Schema.
- With no `name` and no `title`, the wire name is `response`.
- `additionalProperties: false` is written by hand. Schematist would have set it.
- Every property is required, so `strict` is true.

**Files**

| File | Role |
| --- | --- |
| [`berth_slip.rb`](berth_slip.rb) | Passes the hash to `with_schema` |
| [`berth_slip_test.rb`](berth_slip_test.rb) | Replays the cassette |
| [`cassettes/berth_slip.yml`](cassettes/berth_slip.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/05-friday-harbor-berth-slip/berth_slip_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/05-friday-harbor-berth-slip/berth_slip_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
