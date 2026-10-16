# Configuration and contexts · 13 · Maputo pão and chapas router

The overnight desk in Maputo vends a context for Padaria da Beira and
one for the Terminal da Junta chapas rank. The bakery chat sets a desk
header. The rank chat is opened on the global config and rebound with
`with_context`. The catalog title is still in place after both briefs.

**What it teaches**

- A small router object can vend `RubyLLM.context` per tenant and chat
  once on each.
- `with_headers` is a per-chat override. `X-Maputo-Desk` is on the
  bakery request.
- `chat.with_context(ctx)` rebinds a chat that was built globally onto a
  tenant copy. `RubyLLM.config` does not change.

**Files**

| File | Role |
| --- | --- |
| [`desk_router.rb`](desk_router.rb) | Routes two tenants, headers on one chat, `with_context` on the other |
| [`desk_router_test.rb`](desk_router_test.rb) | Replays the cassette and checks titles, headers, and the global title |
| [`cassettes/desk_router.yml`](cassettes/desk_router.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/13-maputo-pao-chapas-router/desk_router.rb
bundle exec ruby features/09-configuration-and-contexts/13-maputo-pao-chapas-router/desk_router_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/13-maputo-pao-chapas-router/desk_router.rb
```

**Model**

Recorded 16 October 2026 on `nvidia/nemotron-3-super-120b-a12b:free`
with `provider: :openrouter`. `CONFIGURATION_OPENROUTER_PAID=1` records
`openai/gpt-4.1-mini` on OpenRouter. A 512-token output cap is set so a
paid request fits this workspace's credits. Fallback:
`LIVE_PROVIDER=openai` records native `gpt-4.1-mini`.
