# Instructions and history · 09 · Hobart hydrometer message roles

The still-house clerk at the Chen family whisky warehouse in Hobart
posts the 08:00 hydrometer round, then reads `chat.messages` back role
by role: system, user, assistant.

**What it teaches**

- `messages.map(&:role)` is the transcript the model saw.
- After one `ask` the roles are `:system`, `:user`, `:assistant`.
- Each message still has its own content. The assistant content is the
  reply `ask` returned.

**Files**

| File | Role |
| --- | --- |
| [`hydrometer_roles.rb`](hydrometer_roles.rb) | Posts the glass and reads the roles |
| [`hydrometer_roles_test.rb`](hydrometer_roles_test.rb) | Replays the cassette and checks each role |
| [`cassettes/hydrometer_roles.yml`](cassettes/hydrometer_roles.yml) | Live recording of the hydrometer ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/09-hobart-hydrometer-roles/hydrometer_roles.rb
bundle exec ruby features/11-instructions-and-history/09-hobart-hydrometer-roles/hydrometer_roles_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/09-hobart-hydrometer-roles/hydrometer_roles.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
