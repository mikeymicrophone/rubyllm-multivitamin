# Agents · 01 · Point Wilson tide clerk

The incoming watch at Point Wilson Light Station reads the posted tide
board for Admiralty Inlet. The tide clerk is a `RubyLLM::Agent` subclass
with `model` and `instructions` declared on the class. Two questions share
that setup: when Alden and Retort can leave the float, then whether to hail
the Fresnel lens crew before Alden sails.

**What it teaches**

- `class TideClerk < RubyLLM::Agent` is the reusable setup.
- `model` names OpenAI `gpt-4.1-mini` with `provider: :openai`.
- `instructions` is the clerk's system prompt. Both questions keep it.
- `Agent.new.ask` sends the transcript and returns a `RubyLLM::Message`.
- `TideClerk.chat` returns a `RubyLLM::Chat`, not an Agent instance.

**Files**

| File | Role |
| --- | --- |
| [`tide_clerk.rb`](tide_clerk.rb) | Declares the agent and asks the two watch questions |
| [`tide_clerk_test.rb`](tide_clerk_test.rb) | Replays the cassette and checks the brief, the macros, and the roles |
| [`cassettes/tide_clerk.yml`](cassettes/tide_clerk.yml) | The two Responses round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/14-agents/01-point-wilson-tide-clerk/tide_clerk.rb
bundle exec ruby features/14-agents/01-point-wilson-tide-clerk/tide_clerk_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/14-agents/01-point-wilson-tide-clerk/tide_clerk.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap allows.

**Model**

`gpt-4.1-mini` on OpenAI after OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`
answered `free-models-per-day`. Fallback: that free slug via
`LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-2.6b:free`. Checked
15 October 2026.
