# Provider tools and citations · 11 · Hood Head agent provider tools

The clerk at Hood Head, on the west shore of Hood Canal, is a
`RubyLLM::Agent` whose extra tool is provider-hosted web search. Two
questions share that setup: the NOAA hail, then whether to bother the
lens crew before Alden copies the gauge.

**What it teaches**

- `provider_tools :web_search` is the agent macro.
- `Agent.new.ask` runs that search. There is no separate
  `with_provider_tools` on the instance.
- `WatchClerk.chat` returns a `RubyLLM::Chat`, not an Agent.
- A second `ask` keeps the earlier hail.

**Files**

| File | Role |
| --- | --- |
| [`watch_agent.rb`](watch_agent.rb) | Declares the Hood Head clerk and asks twice |
| [`watch_agent_test.rb`](watch_agent_test.rb) | Replays the cassette |
| [`cassettes/watch_agent.yml`](cassettes/watch_agent.yml) | Live OpenAI recording of both turns |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/11-hood-head-agent-tools/watch_agent_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/11-hood-head-agent-tools/watch_agent_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
