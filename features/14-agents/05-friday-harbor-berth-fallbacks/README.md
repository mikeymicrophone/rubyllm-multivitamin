# Agents · 05 · Friday Harbor berth fallbacks

The berth clerk at Friday Harbor first aims at a slug the registry never
listed. The agent's `fallbacks` list does not treat that 400 as transient.
Naming `BadRequestError` on `on:` lets the slip sheet reach OpenAI.

**What it teaches**

- `fallbacks` on an Agent is `with_fallbacks` on every chat it builds.
- `Fallback::DEFAULT_ERRORS` does not include `BadRequestError`.
- `on: [BadRequestError]` is what lets the 400 hop to `gpt-4.1-mini`.

**Files**

| File | Role |
| --- | --- |
| [`berth_fallbacks.rb`](berth_fallbacks.rb) | Declares the berth clerk and tries both fallback lists |
| [`berth_fallbacks_test.rb`](berth_fallbacks_test.rb) | Checks the 400, then the rescued slip 14 |
| [`cassettes/berth_fallbacks.yml`](cassettes/berth_fallbacks.yml) | OpenRouter 400s and the OpenAI recovery |

**Try it**

```sh
bundle exec ruby features/14-agents/05-friday-harbor-berth-fallbacks/berth_fallbacks.rb
bundle exec ruby features/14-agents/05-friday-harbor-berth-fallbacks/berth_fallbacks_test.rb
```

**Model**

Unlisted OpenRouter slug `friday-harbor-berth-unlisted`, then OpenAI
`gpt-4.1-mini`. Checked 15 October 2026.
