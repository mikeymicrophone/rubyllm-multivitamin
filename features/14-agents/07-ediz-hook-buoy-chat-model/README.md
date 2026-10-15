# Agents · 07 · Ediz Hook buoy chat model

The buoy clerk at Ediz Hook posts bell buoy 2's 12.6 volts on a persisted
log. `chat_model` turns the agent into Rails mode: `create!` returns the
`BuoyLog` record, and `ask` writes the turns.

**What it teaches**

- `chat_model BuoyLog` activates `create` / `create!` / `find`.
- `BuoyClerk.create!` returns the ActiveRecord chat, not an Agent wrapper.
- `ask` on that record persists the system, user, and assistant rows.
- Calling `create!` without `chat_model` raises `ArgumentError`.

**Files**

| File | Role |
| --- | --- |
| [`buoy_chat_model.rb`](buoy_chat_model.rb) | Boots SQLite, declares the clerk, and creates the log |
| [`buoy_chat_model_test.rb`](buoy_chat_model_test.rb) | Checks persistence, the voltage, and the model id |
| [`cassettes/buoy_chat_model.yml`](cassettes/buoy_chat_model.yml) | The battery-card round-trip |

**Try it**

```sh
bundle exec ruby features/14-agents/07-ediz-hook-buoy-chat-model/buoy_chat_model.rb
bundle exec ruby features/14-agents/07-ediz-hook-buoy-chat-model/buoy_chat_model_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI, same as the Rails integration feature. Fallback:
OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. Checked 15 October 2026.
