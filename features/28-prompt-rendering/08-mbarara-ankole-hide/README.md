# Prompt rendering · 08 · Mbarara ankole hide

The hide desk in Mbarara declares `instructions { prompt("instructions") }`
and ships no ERB file. Building the clerk raises before a socket opens.

**What it teaches**

- `instructions { prompt("instructions") }` requires the conventional file.
- `Agent.new` raises `PromptNotFoundError` when that file is absent.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`ankole_hide.rb`](ankole_hide.rb) | Builds a clerk whose prompt is missing |
| [`ankole_hide_test.rb`](ankole_hide_test.rb) | Checks the class and the path |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/08-mbarara-ankole-hide/ankole_hide.rb
bundle exec ruby features/28-prompt-rendering/08-mbarara-ankole-hide/ankole_hide_test.rb
```

No API key is required. Checked 16 October 2026.
