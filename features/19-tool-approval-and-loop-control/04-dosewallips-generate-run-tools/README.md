# Tool approval and loop control · 04 · Dosewallips generate then run_tools

The river watch at Dosewallips State Park reads the park gauge and stops
on the staff card. Nobody asks the model to speak again. `halt` is gone
in RubyLLM 2.1.1; `generate` then `run_tools` is the stop.

**What it teaches**

- `generate` is one model move. The staff has not been read yet.
- `run_tools` executes the pending call and appends the `:tool` card.
- The last role is `:tool`. `complete?` is false because the model was
  not asked to continue. `halt` and `RubyLLM::Tool::Halt` are not methods.

**Files**

| File | Role |
| --- | --- |
| [`river_gauge.rb`](river_gauge.rb) | Generates once, runs the staff, and stops |
| [`river_gauge_test.rb`](river_gauge_test.rb) | Checks that halt is gone, and replays the cassette |
| [`cassettes/river_gauge.yml`](cassettes/river_gauge.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/04-dosewallips-generate-run-tools/river_gauge_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/04-dosewallips-generate-run-tools/river_gauge_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
