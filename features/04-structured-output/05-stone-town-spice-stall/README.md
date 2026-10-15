# Structured output · 05 · Stone Town spice stall

The market clerk assigns stall 7 to Amina Clove from a raw JSON Schema hash. No Schematist class is involved, and the schema has no name.

**What it teaches**

- `with_schema` accepts a Hash of JSON Schema.
- With no `name` and no `title`, the wire name is `response`.
- `additionalProperties: false` is written by hand. Schematist would have set it.
- Every property is required, so `strict` is true.

**Files**

| File | Role |
| --- | --- |
| [`spice_stall.rb`](spice_stall.rb) | Passes the hash to `with_schema` |
| [`spice_stall_test.rb`](spice_stall_test.rb) | Replays the cassette |
| [`cassettes/spice_stall.yml`](cassettes/spice_stall.yml) | Live recording of the schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/05-stone-town-spice-stall/spice_stall_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/05-stone-town-spice-stall/spice_stall_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
