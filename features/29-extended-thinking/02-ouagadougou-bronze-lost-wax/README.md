# Extended thinking · 02 · Ouagadougou bronze lost-wax

The bronze yard in Ouagadougou pins `effort: :low`. Aminata pours lot
OUA-2026-1016-B7. `gpt-5-nano` sends `reasoning.effort` and no
temperature. Without `display: :summarized` there is no thinking text.

**What it teaches**

- `with_thinking(effort: :low)` sends `reasoning.effort` `low`.
- `gpt-5-nano` does not take temperature.
- `thinking.text` stays nil unless `display: :summarized`.

**Files**

| File | Role |
| --- | --- |
| [`bronze.rb`](bronze.rb) | Pins low effort and asks |
| [`bronze_test.rb`](bronze_test.rb) | Checks the wire and the nil text |
| [`cassettes/bronze.yml`](cassettes/bronze.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/02-ouagadougou-bronze-lost-wax/bronze.rb
bundle exec ruby features/29-extended-thinking/02-ouagadougou-bronze-lost-wax/bronze_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
