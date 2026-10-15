# Agents · 13 · Admiralty Inlet watch capstone

The overnight watch desk at Point Wilson fills a structured watch card
from the posted tide board, then answers whether to hail the Fresnel lens
crew before Alden sails. The agent carries `model`, `instructions`, `tools`,
and `schema` together.

**What it teaches**

- One `RubyLLM::Agent` subclass can declare tools and an inline schema.
- The first `ask` calls `posted_tide_board` and fills `parsed`.
- `with_schema(nil)` drops the format for the lens question.
- The follow-up still has the board: Alden at 10:46, cabinet until 09:30.

**Files**

| File | Role |
| --- | --- |
| [`watch_capstone.rb`](watch_capstone.rb) | Declares the watch desk and asks both questions |
| [`watch_capstone_test.rb`](watch_capstone_test.rb) | Checks the parsed card, the tool message, and the lens answer |
| [`cassettes/watch_capstone.yml`](cassettes/watch_capstone.yml) | The tool loop plus the prose follow-up |

**Try it**

```sh
bundle exec ruby features/14-agents/13-admiralty-inlet-watch-capstone/watch_capstone.rb
bundle exec ruby features/14-agents/13-admiralty-inlet-watch-capstone/watch_capstone_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. Fallback: OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free`. Checked 15 October 2026.
