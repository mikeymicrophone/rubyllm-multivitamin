# Agents · 12 · Juan de Fuca chart handoff

The chart clerk for the Strait of Juan de Fuca posts the relocated bell
buoy 2. The buoy clerk then wraps that same chat and writes the Ediz Hook
ticket. Routing would pick an agent up front. This handoff keeps the
correction in the transcript.

**What it teaches**

- `BuoyClerk.new(chat: chart.chat)` applies a second agent to one conversation.
- `buoy.chat.equal?(chart.chat)` is true.
- The buoy clerk's instructions land on the same transcript.
- The ticket can name the 270-degree bearing without repeating the notice.

**Files**

| File | Role |
| --- | --- |
| [`chart_handoff.rb`](chart_handoff.rb) | Hands the chart chat to the buoy clerk |
| [`chart_handoff_test.rb`](chart_handoff_test.rb) | Checks the shared object, the bearing, and the second instructions |
| [`cassettes/chart_handoff.yml`](cassettes/chart_handoff.yml) | The two turns on one conversation |

**Try it**

```sh
bundle exec ruby features/14-agents/12-juan-de-fuca-chart-handoff/chart_handoff.rb
bundle exec ruby features/14-agents/12-juan-de-fuca-chart-handoff/chart_handoff_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI after the free OpenRouter daily cap.
`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free`
when that cap allows. Checked 15 October 2026.
