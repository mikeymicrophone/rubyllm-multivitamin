# Embeddings · 06 · Dublin Abbey prompt copy

The prompt at the Abbey files Maurya's Act II entrance twice, then files
the afternoon rain-machine. The two copies of the entrance cue sit on top
of each other. The rain note does not.

**What it teaches**

- The same string, twice in one batch, comes back as two vectors whose
  cosine is 1.0 within four places. This model is deterministic.
- That self-score is higher than the score against a different note from
  the same house.
- One call holds the note, its copy, and the rain.

**Files**

| File | Role |
| --- | --- |
| [`prompt_copy.rb`](prompt_copy.rb) | Embeds the entrance cue twice and the rain |
| [`prompt_copy_test.rb`](prompt_copy_test.rb) | Replays the cassette |
| [`cassettes/prompt_copy.yml`](cassettes/prompt_copy.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/06-dublin-prompt-copy/prompt_copy_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/06-dublin-prompt-copy/prompt_copy_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
