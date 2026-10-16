# Batches · 07 · Luxor alabaster-vase cost until complete

The vase clerk in Luxor files 7 alabaster rims for Nefret. `cost.total`
stays nil until the batch ends.

**What it teaches**

- `batch.cost.total` is `nil` until the batch ends.
- `tokens` stay empty while `messages` are still `nil`.

**Files**

| File | Role |
| --- | --- |
| [`alabaster_vase.rb`](alabaster_vase.rb) | Submits the vase card, refreshes once, reads cost |
| [`alabaster_vase_test.rb`](alabaster_vase_test.rb) | Replays the cassette and checks nil cost while pending |
| [`cassettes/alabaster_vase.yml`](cassettes/alabaster_vase.yml) | Upload, create, and one refresh |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/07-luxor-alabaster-vase/alabaster_vase.rb
bundle exec ruby features/21-batches/07-luxor-alabaster-vase/alabaster_vase_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/07-luxor-alabaster-vase/alabaster_vase.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
