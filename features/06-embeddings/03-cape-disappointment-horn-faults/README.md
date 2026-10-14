# Embeddings · 03 · Cape Disappointment foghorn faults

The horn watch at Cape Disappointment ranks a new compressor complaint
against last week's oil-pressure note and against an Anacortes retort cook.
Cosine similarity puts the two compressor notes together.

**What it teaches**

- Cosine similarity is a Ruby calculation on `embedding.vectors`. RubyLLM
  does not rank the notes for you.
- The catalog does not add the `matrix` gem. The watch computes the score
  from the floats.
- A fault report is nearer its twin than a cook log. The three notes are
  one batch, so the cassette is one round-trip.

**Files**

| File | Role |
| --- | --- |
| [`horn_faults.rb`](horn_faults.rb) | Embeds two compressor notes and a cook log |
| [`horn_faults_test.rb`](horn_faults_test.rb) | Replays the cassette |
| [`cassettes/horn_faults.yml`](cassettes/horn_faults.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/03-cape-disappointment-horn-faults/horn_faults_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/03-cape-disappointment-horn-faults/horn_faults_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
