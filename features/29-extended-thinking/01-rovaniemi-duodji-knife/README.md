# Extended thinking · 01 · Rovaniemi duodji knife

The duodji clerk in Rovaniemi turns thinking on with no options. Aila
hones knife ROV-2026-1016-D3. Nemotron sends `reasoning.enabled true`
and returns thinking text beside the brief.

**What it teaches**

- `with_thinking` with no options uses the model's registered controls.
- On Nemotron that is a toggle: the wire sends `reasoning.enabled true`.
- `thinking.text` is the spoken reasoning, not the brief.

**Files**

| File | Role |
| --- | --- |
| [`duodji.rb`](duodji.rb) | Enables thinking and asks |
| [`duodji_test.rb`](duodji_test.rb) | Checks the text and the wire |
| [`cassettes/duodji.yml`](cassettes/duodji.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/01-rovaniemi-duodji-knife/duodji.rb
bundle exec ruby features/29-extended-thinking/01-rovaniemi-duodji-knife/duodji_test.rb
```

Re-record with `LIVE=1 OPENROUTER_API_KEY=...`.

**Model**

OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. Checked 16 October 2026.
