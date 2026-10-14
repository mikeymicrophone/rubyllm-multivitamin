# Models and providers · 07 · Budd Inlet oyster-lease catalogs

The lease clerk on a Budd Inlet oyster barge keeps the vector catalog of
growing-area notes in one drawer and the chat clerks in another. An
embedding model is not a radio clerk, even when the names look similar.

**What it teaches**

- `embedding_models` and `chat_models` do not overlap on `[id, provider]`.
- On this bundled registry they also do not overlap on `id` alone.
- `text-embedding-3-small` is type `:embedding` and is not in
  `chat_models`. `gpt-4.1-mini` is type `:chat` and is not in
  `embedding_models`.

**Files**

| File | Role |
| --- | --- |
| [`lease_catalog.rb`](lease_catalog.rb) | Splits the two catalogs and samples one of each |
| [`lease_catalog_test.rb`](lease_catalog_test.rb) | Asserts the empty overlap |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/07-budd-inlet-oyster-leases/lease_catalog.rb
bundle exec ruby features/08-models-and-providers/07-budd-inlet-oyster-leases/lease_catalog_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
