# Structured output · 09 · Bremerton dry dock gate

The dry dock clerk at the Port of Bremerton records the gate, tells the crew in a sentence whether they can walk the sill, then files an afternoon note. The sentence is prose. The note is a second schema.

**What it teaches**

- `with_schema` stays on the chat until you replace it.
- `with_schema(nil)` drops `text.format`. The next request has no `json_schema`.
- The first JSON answer is still in `input` on that prose turn. This cassette's second request contains `18.4`.
- A later `with_schema` installs a different name, `crew_note`.

**Files**

| File | Role |
| --- | --- |
| [`gate_state.rb`](gate_state.rb) | Schema, prose, then a second schema |
| [`gate_state_test.rb`](gate_state_test.rb) | Replays the cassette |
| [`cassettes/gate_state.yml`](cassettes/gate_state.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/09-bremerton-dry-dock-gate/gate_state_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/09-bremerton-dry-dock-gate/gate_state_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. Three Responses calls.
