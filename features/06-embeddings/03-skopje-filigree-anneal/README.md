# Embeddings · 03 · Skopje filigree anneal faults

The silversmith in the Old Bazaar ranks a new annealing-torch complaint
against last week's gas-pressure note and against a cheese burek bake.
Cosine similarity puts the two torch notes together.

**What it teaches**

- A lexical `Array` refinement delegates `cosine_sim` to the shared vector helper, which uses `zip` and `sum` reductions.
- Cosine similarity is a Ruby calculation on `embedding.vectors`. RubyLLM
  does not rank the notes for you.
- The catalog does not add the `matrix` gem. The bench computes the score
  from the floats.
- A fault report is nearer its twin than a bakery log. The three notes are
  one batch, so the cassette is one round-trip.

**Files**

| File | Role |
| --- | --- |
| [`anneal_faults.rb`](anneal_faults.rb) | Embeds two torch notes and a burek log |
| [`anneal_faults_test.rb`](anneal_faults_test.rb) | Replays the cassette |
| [`cassettes/anneal_faults.yml`](cassettes/anneal_faults.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/03-skopje-filigree-anneal/anneal_faults_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/03-skopje-filigree-anneal/anneal_faults_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
