# Structured output · 02 · New Dungeness lens drawers

The lens keeper inventories three drawers of the fourth-order cabinet at New Dungeness. The schema is an array of objects, one per drawer.

**What it teaches**

- `array` with an `object` block is one Hash per drawer.
- `response.parsed["drawers"]` is an Array. Spare counts are integers.
- The item schema on the wire is `type: array` with an object `items` schema.

**Files**

| File | Role |
| --- | --- |
| [`lens_drawers.rb`](lens_drawers.rb) | Asks for the cabinet card |
| [`lens_drawers_test.rb`](lens_drawers_test.rb) | Replays the cassette |
| [`cassettes/lens_drawers.yml`](cassettes/lens_drawers.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/02-new-dungeness-lens-drawers/lens_drawers_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/02-new-dungeness-lens-drawers/lens_drawers_test.rb
```

`LIVE_PROVIDER=openrouter` overwrites this cassette with the free structured-output slug. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
