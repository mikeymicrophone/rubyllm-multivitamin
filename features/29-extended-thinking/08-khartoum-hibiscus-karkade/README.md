# Extended thinking · 08 · Khartoum hibiscus karkade

The karkade desk in Khartoum turns thinking off on Nemotron. Maha
steeps lot KRT-2026-1016-H1. The wire sends `reasoning.enabled false`
and the brief has no thinking text.

**What it teaches**

- `with_thinking(false)` on Nemotron sends `reasoning.enabled false`.
- `thinking.text` on the brief is nil.
- The karkade card is still answered.

**Files**

| File | Role |
| --- | --- |
| [`karkade.rb`](karkade.rb) | Turns thinking off and asks |
| [`karkade_test.rb`](karkade_test.rb) | Checks the wire and the nil text |
| [`cassettes/karkade.yml`](cassettes/karkade.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/08-khartoum-hibiscus-karkade/karkade.rb
bundle exec ruby features/29-extended-thinking/08-khartoum-hibiscus-karkade/karkade_test.rb
```

Re-record with `LIVE=1 OPENROUTER_API_KEY=...`.

**Model**

OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. Checked 16 October 2026.
