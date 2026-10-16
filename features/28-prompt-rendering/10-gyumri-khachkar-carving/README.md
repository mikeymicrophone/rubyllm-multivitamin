# Prompt rendering · 10 · Gyumri khachkar carving

The khachkar yard in Gyumri renders the question as well as the
standing orders. Aram dresses cross GYU-2026-1016-K8 at 11:40.

**What it teaches**

- `ask` can take a rendered question template, not only a literal string.
- Instructions and the question can come from different prompt files.
- Locals in the question template are ERB, not a second provider call.

**Files**

| File | Role |
| --- | --- |
| [`khachkar.rb`](khachkar.rb) | Renders both files and asks |
| [`khachkar_test.rb`](khachkar_test.rb) | Checks the question locals and the brief |
| [`app/prompts/khachkar/instructions.txt.erb`](app/prompts/khachkar/instructions.txt.erb) | The standing orders |
| [`app/prompts/khachkar/question.txt.erb`](app/prompts/khachkar/question.txt.erb) | The board question |
| [`cassettes/khachkar.yml`](cassettes/khachkar.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/10-gyumri-khachkar-carving/khachkar.rb
bundle exec ruby features/28-prompt-rendering/10-gyumri-khachkar-carving/khachkar_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
