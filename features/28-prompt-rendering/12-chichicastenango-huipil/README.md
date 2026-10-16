# Prompt rendering · 12 · Chichicastenango huipil

The backstrap loft in Chichicastenango keeps a tone card that names
Ixchel when the local is passed and stays generic when it is not.

**What it teaches**

- `local_assigns` reads an optional local without raising.
- A missing weaver name still renders.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`huipil.rb`](huipil.rb) | Renders the tone with and without the weaver |
| [`huipil_test.rb`](huipil_test.rb) | Checks both strings |
| [`app/prompts/huipil/tone.txt.erb`](app/prompts/huipil/tone.txt.erb) | The optional-local card |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/12-chichicastenango-huipil/huipil.rb
bundle exec ruby features/28-prompt-rendering/12-chichicastenango-huipil/huipil_test.rb
```

No API key is required. Checked 16 October 2026.
