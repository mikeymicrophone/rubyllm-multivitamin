# Tools · 10 · Aalsmeer greenhouse PAR

The greenhouse watch at Aalsmeer reads the east bench and the west bench
in one turn. `calls: :many` sends `parallel_tool_calls`. Each `execute`
returns a Hash, so the tool message is JSON: 18 and 22 micromoles, peaks
27 and 31.

**What it teaches**

- `with_tool_options(calls: :many)` sends `parallel_tool_calls` true so
  one assistant turn can carry two calls.
- A Hash return is JSON on the tool message. A String return, as on the
  auction chalkboard, is not.

**Files**

| File | Role |
| --- | --- |
| [`bench_par.rb`](bench_par.rb) | Forces two parallel PAR calls, one per bench |
| [`bench_par_test.rb`](bench_par_test.rb) | Checks both JSON results and replays the cassette |
| [`cassettes/bench_par.yml`](cassettes/bench_par.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/10-aalsmeer-greenhouse-par/bench_par_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/10-aalsmeer-greenhouse-par/bench_par_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
