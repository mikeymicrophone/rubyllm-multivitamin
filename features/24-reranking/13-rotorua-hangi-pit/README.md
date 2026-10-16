# Reranking · 13 · Rotorua hāngī pit

The pit clerk in Rotorua ranks eight hāngī notes, keeps three, maps the
winner back to pit D, and briefs 11:40. Tokens sit on the ranked object
when Voyage reports them.

**What it teaches**

- Capstone: `top_n: 3`, `index` back to the pit structs, then a brief.
- Eight notes still go on the wire.
- The cassette is rerank then Responses.

**Files**

| File | Role |
| --- | --- |
| [`hangi_desk.rb`](hangi_desk.rb) | Reranks, maps, briefs |
| [`hangi_desk_test.rb`](hangi_desk_test.rb) | Checks pit D and the two calls |
| [`cassettes/hangi_desk.yml`](cassettes/hangi_desk.yml) | Rerank then Responses |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/13-rotorua-hangi-pit/hangi_desk.rb
bundle exec ruby features/24-reranking/13-rotorua-hangi-pit/hangi_desk_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/13-rotorua-hangi-pit/hangi_desk.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter, then `gpt-4.1-mini` on OpenAI.
Checked 16 October 2026.
