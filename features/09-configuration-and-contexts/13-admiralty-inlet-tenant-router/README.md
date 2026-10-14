# Configuration and contexts · 13 · Admiralty Inlet tenant router

The overnight desk on Admiralty Inlet vends a context for Point Wilson and
one for the Anacortes cannery. The station chat sets a watch header. The
cannery chat is opened on the global config and rebound with
`with_context`. The catalog title is still in place after both briefs.

**What it teaches**

- A small router object can vend `RubyLLM.context` per tenant and chat
  once on each.
- `with_headers` is a per-chat override. `X-Admiralty-Watch` is on the
  station request.
- `chat.with_context(ctx)` rebinds a chat that was built globally onto a
  tenant copy. `RubyLLM.config` does not change.

**Files**

| File | Role |
| --- | --- |
| [`watch_router.rb`](watch_router.rb) | Routes two tenants, headers on one chat, `with_context` on the other |
| [`watch_router_test.rb`](watch_router_test.rb) | Replays the cassette and checks titles, headers, and the global title |
| [`cassettes/watch_router.yml`](cassettes/watch_router.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/13-admiralty-inlet-tenant-router/watch_router.rb
bundle exec ruby features/09-configuration-and-contexts/13-admiralty-inlet-tenant-router/watch_router_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/13-admiralty-inlet-tenant-router/watch_router.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
