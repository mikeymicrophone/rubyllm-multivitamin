# Chat basics · 12 · Accession tag for the Singapore Botanic Gardens

The herbarium clerk has correction slip SBG-18465 for sheet SBG-18465: living-collection tag DH moved 300 cm northwest. The first ask is capped at 16 output tokens. The clerk reads the note, and if it is empty or cut off, clears the cap and asks again.

**What it teaches**

- `with_max_output_tokens` caps the next reply. A short or empty `content` is still a message. On this recording the cap cut the note mid-sentence and `finish_reason` is `:max_tokens`.
- `max_tokens?` is true when the finish reason is the cap. `content.to_s.strip` is how you see that the note is too short to pencil onto the bed plan.
- `response.raw` is the `Faraday::Response`. `raw.status` is the HTTP status beside the parsed message.
- Clearing the cap with `with_max_output_tokens(nil)` and asking again posts the full correction on the same chat.

**Files**

| File | Role |
| --- | --- |
| [`accession_notice.rb`](accession_notice.rb) | Caps the first note, then posts a full correction when the note is short |
| [`accession_notice_test.rb`](accession_notice_test.rb) | Replays the cassette and checks the short-note rule and both statuses |
| [`cassettes/accession_notice.yml`](cassettes/accession_notice.yml) | The Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/12-singapore-accession-tag/accession_notice.rb
bundle exec ruby features/01-chat-basics/12-singapore-accession-tag/accession_notice_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. The capped ask returned HTTP 200 with a 53-character fragment and `finish_reason` `:max_tokens`. The second ask, with the cap cleared, posted the correction: sheet SBG-18465, tag DH, 300 cm northwest. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/12-singapore-accession-tag/accession_notice.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
