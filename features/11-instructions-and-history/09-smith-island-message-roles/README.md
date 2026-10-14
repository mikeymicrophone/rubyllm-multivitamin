# Instructions and history · 09 · Smith Island message roles

The weather keeper at Smith Island Light posts the 08:00 barometer
round, then reads `chat.messages` back role by role: system, user,
assistant.

**What it teaches**

- `messages.map(&:role)` is the transcript the model saw.
- After one `ask` the roles are `:system`, `:user`, `:assistant`.
- Each message still has its own content. The assistant content is the
  reply `ask` returned.

**Files**

| File | Role |
| --- | --- |
| [`message_roles.rb`](message_roles.rb) | Posts the glass and reads the roles |
| [`message_roles_test.rb`](message_roles_test.rb) | Replays the cassette and checks each role |
| [`cassettes/message_roles.yml`](cassettes/message_roles.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/09-smith-island-message-roles/message_roles.rb
bundle exec ruby features/11-instructions-and-history/09-smith-island-message-roles/message_roles_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/09-smith-island-message-roles/message_roles.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
