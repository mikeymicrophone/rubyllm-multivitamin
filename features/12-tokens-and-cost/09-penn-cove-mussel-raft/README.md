# Tokens and cost · 09 · Penn Cove mussel-raft tenant tallies

The overnight desk on Penn Cove files one question for the mussel raft
and one for the Coupeville ferry dock. Each tenant owns its chat through
`RubyLLM.with_usage_owner`. `Cost.aggregate` sums the two messages.

**What it teaches**

- `with_usage_owner` stamps each attempt. `chat.usage_entries` carry that
  owner even without Rails.
- Two chats keep separate `chat.cost` totals.
- `RubyLLM::Cost.aggregate` sums the message costs. On these free slugs
  each total is the reported `0`.

**Files**

| File | Role |
| --- | --- |
| [`mussel_raft.rb`](mussel_raft.rb) | Asks one question per tenant and aggregates the costs |
| [`mussel_raft_test.rb`](mussel_raft_test.rb) | Replays the cassette and checks the owners |
| [`cassettes/mussel_raft.yml`](cassettes/mussel_raft.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/09-penn-cove-mussel-raft/mussel_raft.rb
bundle exec ruby features/12-tokens-and-cost/09-penn-cove-mussel-raft/mussel_raft_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/09-penn-cove-mussel-raft/mussel_raft.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
