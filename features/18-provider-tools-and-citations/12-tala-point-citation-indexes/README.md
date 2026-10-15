# Provider tools and citations · 12 · Tala Point citation indexes

The clerk at Tala Point, on the west shore of Hood Canal, posts footnote
marks on the NOAA hail so the relief can open the cited span.
OpenAI web-search citations carry `start_index` and `end_index`.

**What it teaches**

- `citation.start_index` / `end_index` mark a range in `response.content`.
- `content[start_index...end_index]` equals `citation.text`.
- `Citation#to_h` omits nil fields. This recording has `url` and `title`,
  not `cited_text` or PDF page numbers.

**Files**

| File | Role |
| --- | --- |
| [`index_marks.rb`](index_marks.rb) | Hails NOAA and keeps the citation spans |
| [`index_marks_test.rb`](index_marks_test.rb) | Replays the cassette |
| [`cassettes/index_marks.yml`](cassettes/index_marks.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/12-tala-point-citation-indexes/index_marks_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/12-tala-point-citation-indexes/index_marks_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
