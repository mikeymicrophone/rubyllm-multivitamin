# Error handling · 09 · Salalah frankincense scale

The beam-scale in a Salalah frankincense loft is offline. The clerk's
`salalah_beam_scale` tool returns `{ error: }` so the model can tell the
sorter to weigh the Hojari lot on the hand-beam and quote 04:10. A
second tool, `scale_house_lamp`, raises `ScaleHouseDark` when the lamp
is out. That exception is for the application, not for the model.

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
| [`scale_error.rb`](scale_error.rb) | Runs the offline scale, then the lamp |
| [`scale_error_test.rb`](scale_error_test.rb) | Checks the tool JSON, the brief, and the raise |
| [`cassettes/scale_error.yml`](cassettes/scale_error.yml) | The scale round-trip and the lamp call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/09-salalah-frankincense-scale/scale_error.rb
bundle exec ruby features/13-error-handling/09-salalah-frankincense-scale/scale_error_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/09-salalah-frankincense-scale/scale_error.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
