# Prompt rendering · 02 · Bandung batik stamp

The batik desk in Bandung looks up a canting prompt that was never
cut. `render_prompt` raises before a socket opens.

**What it teaches**

- A missing `.txt.erb` raises `PromptNotFoundError`.
- That class inherits `StandardError`, not `RubyLLM::Error`.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`batik_stamp.rb`](batik_stamp.rb) | Asks for a prompt that is not on disk |
| [`batik_stamp_test.rb`](batik_stamp_test.rb) | Checks the class and the missing cassette |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/02-bandung-batik-stamp/batik_stamp.rb
bundle exec ruby features/28-prompt-rendering/02-bandung-batik-stamp/batik_stamp_test.rb
```

No API key is required. Checked 16 October 2026.
