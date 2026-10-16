# Reranking · 10 · Nadi ginger shed

The shed clerk in Nadi ranks two ginger crates and forgets `model:`.
Rerank catalogs have no default. Ruby raises `ArgumentError` before a
request is sent.

**What it teaches**

- `model:` is a required keyword.
- The message names `model`.
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`ginger_missing.rb`](ginger_missing.rb) | Calls rerank without `model:` |
| [`ginger_missing_test.rb`](ginger_missing_test.rb) | Checks the class and the missing cassette |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/10-nadi-ginger-shed/ginger_missing.rb
bundle exec ruby features/24-reranking/10-nadi-ginger-shed/ginger_missing_test.rb
```

No API key is required.

**Model**

None. The call never leaves the desk. Checked 16 October 2026.
