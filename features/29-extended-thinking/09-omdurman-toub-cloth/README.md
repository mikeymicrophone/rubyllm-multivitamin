# Extended thinking · 09 · Omdurman toub cloth

The toub stall in Omdurman asks on OpenAI with a summarized signature,
then switches the chat to Nemotron. Sittina dyes lot OMD-2026-1016-T9.
The follow-up request does not replay the encrypted block.

**What it teaches**

- Thinking stays with the provider that produced it.
- `with_model` to OpenRouter drops the OpenAI signature on the next ask.
- The earlier toub question stays on the transcript.

**Files**

| File | Role |
| --- | --- |
| [`toub.rb`](toub.rb) | Asks, switches provider, asks again |
| [`toub_test.rb`](toub_test.rb) | Checks the follow-up body |
| [`cassettes/toub.yml`](cassettes/toub.yml) | Both asks |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/09-omdurman-toub-cloth/toub.rb
bundle exec ruby features/29-extended-thinking/09-omdurman-toub-cloth/toub_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=... OPENROUTER_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`, then OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`.
Checked 16 October 2026.
