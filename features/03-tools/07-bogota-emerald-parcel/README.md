# Tools · 07 · Bogotá emerald parcel

The parcel clerk at the Muzo desk in Bogotá is asked for lot CO-17. That
lot is not on the desk. The tool returns `{ error: }` as JSON and names
CO-4. The model calls the tool again and reads 12.6 ct.

**What it teaches**

- A miss returns `{ error: }`. That hash is JSON on the tool message,
  and the model can call the tool again.
- `choice: :required` is on the first request only. After the tool runs,
  RubyLLM clears it, so the retry is the model's own.

**Files**

| File | Role |
| --- | --- |
| [`emerald_parcel.rb`](emerald_parcel.rb) | Returns an error hash on CO-17, then the CO-4 card |
| [`emerald_parcel_test.rb`](emerald_parcel_test.rb) | Checks both tool messages and replays the cassette |
| [`cassettes/emerald_parcel.yml`](cassettes/emerald_parcel.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/07-bogota-emerald-parcel/emerald_parcel_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/07-bogota-emerald-parcel/emerald_parcel_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
