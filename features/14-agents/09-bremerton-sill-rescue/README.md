# Agents · 09 · Bremerton sill rescue

The dry dock clerk at Bremerton aims at a slug the registry never listed.
`rescue_from` on the agent instance turns that 400 into a posted sill of
4.2 fathoms. `SillClerk.chat` is a plain `RubyLLM::Chat`, so the same 400
still leaves the desk.

**What it teaches**

- `rescue_from RubyLLM::BadRequestError` runs on `ask` for agent instances.
- Without a `raise` in the handler, the handler's return value is the result.
- `SillClerk.chat` is not wrapped, so `rescue_from` does not apply there.
- Handlers apply to `ask`, `say`, `ask_later`, `complete`, `generate`,
  `run_tools`, `step`, and `count_tokens`.

**Files**

| File | Role |
| --- | --- |
| [`sill_rescue.rb`](sill_rescue.rb) | Declares the handler and compares instance vs chat |
| [`sill_rescue_test.rb`](sill_rescue_test.rb) | Checks the swallowed string and the raised 400 |
| [`cassettes/sill_rescue.yml`](cassettes/sill_rescue.yml) | Two OpenRouter 400s |

**Try it**

```sh
bundle exec ruby features/14-agents/09-bremerton-sill-rescue/sill_rescue.rb
bundle exec ruby features/14-agents/09-bremerton-sill-rescue/sill_rescue_test.rb
```

**Model**

Unlisted OpenRouter slug `bremerton-sill-unlisted`. Checked 15 October 2026.
