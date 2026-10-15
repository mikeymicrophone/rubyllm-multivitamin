# Agents · 11 · Port Angeles net loft switch

The twine clerk in the Port Angeles net loft answers off spool 14, then
`with_model` switches the slug before the bench asks how many feet remain.
The tarred-nylon ticket stays on the transcript.

**What it teaches**

- `agent.with_model` switches the model on an agent that already has turns.
- The first user turn still contains `3-strand tarred nylon`.
- The follow-up message's `model` is the new slug.
- `agent.model.id` matches that follow-up.

**Files**

| File | Role |
| --- | --- |
| [`net_switch.rb`](net_switch.rb) | Asks the ticket, switches, then asks the remaining feet |
| [`net_switch_test.rb`](net_switch_test.rb) | Checks both slugs and the kept ticket |
| [`cassettes/net_switch.yml`](cassettes/net_switch.yml) | Two Chat Completions round-trips on two slugs |

**Try it**

```sh
bundle exec ruby features/14-agents/11-port-angeles-net-loft-switch/net_switch.rb
bundle exec ruby features/14-agents/11-port-angeles-net-loft-switch/net_switch_test.rb
```

**Model**

`gpt-4.1-mini`, then `gpt-4o-mini` after `with_model`. The message `model` is
the dated snapshot (`gpt-4o-mini-2024-07-18`); `agent.model.id` stays the
id passed to `with_model`. `LIVE_PROVIDER=openrouter` records the free slug
then `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
