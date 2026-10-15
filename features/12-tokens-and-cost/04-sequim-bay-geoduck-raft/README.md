# Tokens and cost · 04 · Sequim Bay geoduck raft versus hail

The harvest clerk on the Sequim Bay geoduck raft off Gibson Spit posts
lot SQB-441 twice: once from the full harvest log, once from a one-line
hail. Two chats. The longer prompt reports more input tokens.

**What it teaches**

- Two chats share instructions and differ only in the user prompt.
- The longer lot card reports more `tokens.input` than the hail.
- Output counts are still present. The comparison the test locks is input.

**Files**

| File | Role |
| --- | --- |
| [`geoduck_raft.rb`](geoduck_raft.rb) | Asks the lot card and the hail on separate chats |
| [`geoduck_raft_test.rb`](geoduck_raft_test.rb) | Replays the cassette and compares the input counts |
| [`cassettes/geoduck_raft.yml`](cassettes/geoduck_raft.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/04-sequim-bay-geoduck-raft/geoduck_raft.rb
bundle exec ruby features/12-tokens-and-cost/04-sequim-bay-geoduck-raft/geoduck_raft_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/12-tokens-and-cost/04-sequim-bay-geoduck-raft/geoduck_raft.rb
```

**Model**

`gpt-4.1-mini` on OpenAI. The free OpenRouter slug hit `free-models-per-day`
while this slot was being re-recorded. Fallback:
`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free`
when the daily cap allows. Checked 15 October 2026.
