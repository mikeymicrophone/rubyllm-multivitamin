# Provider tools and citations · 13 · Termination Point search desk capstone

The overnight desk at Termination Point, at the mouth of Liberty Bay,
hails NOAA for the Port Townsend gauge, then interpolates Alden's
kelp-ledge height. One agent declares `:web_search` and
`:code_execution` together.

**What it teaches**

- `provider_tools :web_search, :code_execution` on a `RubyLLM::Agent`.
- The first ask fills `response.citations` from the NOAA hail.
- The second ask records `code_interpreter_call` and the exact
  interpolated height.
- Both tools stay on every request. Each message keeps its own
  `server_tool_calls`.

**Files**

| File | Role |
| --- | --- |
| [`search_desk.rb`](search_desk.rb) | Hails NOAA, then interpolates the ledge |
| [`search_desk_test.rb`](search_desk_test.rb) | Replays the cassette |
| [`cassettes/search_desk.yml`](cassettes/search_desk.yml) | Live OpenAI recording of both turns |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/13-termination-point-search-desk/search_desk_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/13-termination-point-search-desk/search_desk_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
