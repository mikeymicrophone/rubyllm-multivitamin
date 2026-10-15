# Structured output · 02 · Thimphu thangka pigment drawers

The pigment keeper inventories three drawers of mineral colour at a thangka atelier in Thimphu. The schema is an array of objects, one per drawer.

**What it teaches**

- `array` with an `object` block is one Hash per drawer.
- `response.parsed["drawers"]` is an Array. Spare counts are integers.
- The item schema on the wire is `type: array` with an object `items` schema.

**Files**

| File | Role |
| --- | --- |
| [`pigment_drawers.rb`](pigment_drawers.rb) | Asks for the cabinet card |
| [`pigment_drawers_test.rb`](pigment_drawers_test.rb) | Replays the cassette |
| [`cassettes/pigment_drawers.yml`](cassettes/pigment_drawers.yml) | Live recording of the schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/02-thimphu-thangka-drawers/pigment_drawers_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/02-thimphu-thangka-drawers/pigment_drawers_test.rb
```

`LIVE_PROVIDER=openrouter` overwrites this cassette with the free structured-output slug. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
