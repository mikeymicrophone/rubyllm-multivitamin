# Error handling · 09 · West Point gauge error

The NOAA gauge at West Point, off Shilshole, is offline. The clerk's
`west_point_gauge` tool returns `{ error: }` so the model can tell the
watch to leadline the entrance and quote 04:10. A second tool,
`gauge_house_lamp`, raises `GaugeHouseDark` when the lamp is out. That
exception is for the application, not for the model.

**What it teaches**

- Returning `{ error: }` from `execute` sends that Hash to the model as
  the tool message. The chat continues.
- Raising from `execute` stops the interaction. The class does not
  inherit `RubyLLM::Error`.
- `with_tool_options(choice:)` forces each tool so the cassette shows
  both paths.

**Files**

| File | Role |
| --- | --- |
| [`gauge_error.rb`](gauge_error.rb) | Runs the offline gauge, then the lamp |
| [`gauge_error_test.rb`](gauge_error_test.rb) | Checks the tool JSON, the brief, and the raise |
| [`cassettes/gauge_error.yml`](cassettes/gauge_error.yml) | The gauge round-trip and the lamp call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/09-west-point-gauge-error/gauge_error.rb
bundle exec ruby features/13-error-handling/09-west-point-gauge-error/gauge_error_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/09-west-point-gauge-error/gauge_error.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 15 October 2026.
