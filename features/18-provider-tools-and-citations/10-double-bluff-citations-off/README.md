# Provider tools and citations · 10 · Double Bluff citations off

The clerk at Double Bluff, on the southwest shore of Whidbey, turns
document citations off, then still has to hail NOAA. Search citations
land on the reply anyway. `with_citations` only covers attached
documents.

**What it teaches**

- `with_citations` then `with_citations(false)` clears the document flag.
- `with_citations(nil)` raises `ArgumentError`: the flag is only true
  or false.
- `chat.citations` is `false` when the search runs.
- `response.citations` from `:web_search` is still populated.

**Files**

| File | Role |
| --- | --- |
| [`citations_off.rb`](citations_off.rb) | Turns document citations off, then searches |
| [`citations_off_test.rb`](citations_off_test.rb) | Replays the cassette |
| [`cassettes/citations_off.yml`](cassettes/citations_off.yml) | Live OpenAI recording of the search |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/10-double-bluff-citations-off/citations_off_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/10-double-bluff-citations-off/citations_off_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
