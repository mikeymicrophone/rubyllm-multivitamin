# Prompt rendering · 11 · Harar bookbinding

The bindery in Harar passes Zahra's name through an `instructions`
lambda into the conventional ERB file. She sews quire HAR-2026-1016-Q4
at 08:50.

**What it teaches**

- `instructions display_name: -> { }` passes locals to the conventional prompt.
- The lambda is evaluated when the agent is built.
- The ERB file is `app/prompts/<agent>/instructions.txt.erb`.

**Files**

| File | Role |
| --- | --- |
| [`bookbinding.rb`](bookbinding.rb) | Builds the clerk and asks |
| [`bookbinding_test.rb`](bookbinding_test.rb) | Checks the system turn and the brief |
| [`app/prompts/harar_bookbinding/bindery_clerk/instructions.txt.erb`](app/prompts/harar_bookbinding/bindery_clerk/instructions.txt.erb) | The conventional prompt |
| [`cassettes/bookbinding.yml`](cassettes/bookbinding.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/11-harar-bookbinding/bookbinding.rb
bundle exec ruby features/28-prompt-rendering/11-harar-bookbinding/bookbinding_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
