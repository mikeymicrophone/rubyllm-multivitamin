# Extended thinking · 11 · Hawassa sidama coffee

The sidama mill in Hawassa pins thinking on the agent class. Tigist
pulps lot HAW-2026-1016-C3. `Agent.new.ask` sends medium effort and a
summarized display.

**What it teaches**

- An Agent `thinking` macro maps onto `Chat#with_thinking`.
- `display: :summarized` and `effort: :medium` ride on the class.
- `Agent.new.ask` runs that configuration.

**Files**

| File | Role |
| --- | --- |
| [`sidama.rb`](sidama.rb) | Builds the mill clerk and asks |
| [`sidama_test.rb`](sidama_test.rb) | Checks the brief and the wire |
| [`cassettes/sidama.yml`](cassettes/sidama.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/11-hawassa-sidama-coffee/sidama.rb
bundle exec ruby features/29-extended-thinking/11-hawassa-sidama-coffee/sidama_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`. Checked 16 October 2026.
