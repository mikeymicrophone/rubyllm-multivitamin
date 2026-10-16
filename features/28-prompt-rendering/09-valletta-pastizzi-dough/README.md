# Prompt rendering · 09 · Valletta pastizzi dough

The pastizzi stall in Valletta maps a known card name onto a prompt
path. A traversal string is `ArgumentError` before ERB runs. Lucia
folds lot VLT-2026-1016-P6.

**What it teaches**

- Do not interpolate an untrusted stall name into a prompt path.
- Map a known card onto a constant prompt name.
- An unknown card is `ArgumentError` before `render_prompt` runs.

**Files**

| File | Role |
| --- | --- |
| [`pastizzi.rb`](pastizzi.rb) | Maps the card, rejects the traversal, asks |
| [`pastizzi_test.rb`](pastizzi_test.rb) | Checks the brief and the ArgumentError |
| [`app/prompts/pastizzi/instructions.txt.erb`](app/prompts/pastizzi/instructions.txt.erb) | The known card |
| [`cassettes/pastizzi.yml`](cassettes/pastizzi.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/09-valletta-pastizzi-dough/pastizzi.rb
bundle exec ruby features/28-prompt-rendering/09-valletta-pastizzi-dough/pastizzi_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Rendering is local. Checked 16 October 2026.
