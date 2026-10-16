# Batches · 06 · Berat wood-lattice mix raises

The lattice clerk in Berat tries to file a screen chat and a bark embed
in one batch. RubyLLM raises before any provider call.

**What it teaches**

- A batch takes chats or embedding requests, not both.
- Mixing them raises `ArgumentError` before any HTTP call.

**Files**

| File | Role |
| --- | --- |
| [`wood_lattice.rb`](wood_lattice.rb) | Stages one chat and one embed, then catches ArgumentError |
| [`wood_lattice_test.rb`](wood_lattice_test.rb) | Checks the error class and message |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/06-berat-wood-lattice/wood_lattice.rb
bundle exec ruby features/21-batches/06-berat-wood-lattice/wood_lattice_test.rb
```

This slot makes no HTTP call. There is no cassette.

**Model**

No provider call. The raise happens in `Batch.submit`.
