# Batches · 12 · Split limestone-block headers dropped

The block clerk in Split sets a dawn-cut workshop header, then stages 6
blocks for Ante. The batch JSONL does not carry that header.

**What it teaches**

- `with_headers` stays on the Chat object.
- `chat.render`, which the batch uploads, does not include those headers.

**Files**

| File | Role |
| --- | --- |
| [`limestone_block.rb`](limestone_block.rb) | Sets a workshop header, stages the card, submits |
| [`limestone_block_test.rb`](limestone_block_test.rb) | Replays the cassette and refutes the header |
| [`cassettes/limestone_block.yml`](cassettes/limestone_block.yml) | Upload and create without the workshop header |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/12-split-limestone-block/limestone_block.rb
bundle exec ruby features/21-batches/12-split-limestone-block/limestone_block_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/12-split-limestone-block/limestone_block.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
