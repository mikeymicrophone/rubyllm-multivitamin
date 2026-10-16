# Rails integration · 04 · Kumasi fontomfrom stream

The fontomfrom clerk in Kumasi dictates the call card onto a persisted
drum log. Streaming creates the assistant row empty, then fills that
same row.

**What it teaches**

- A streamed `ask` creates the assistant row before the first chunk, with empty content.
- The joined speech is what the saved assistant row holds after the stream.
- The folder's feature is persistence: the row is the stream target.

**Files**

| File | Role |
| --- | --- |
| [`drum_stream.rb`](drum_stream.rb) | Streams the fontomfrom card into the drum log |
| [`drum_stream_test.rb`](drum_stream_test.rb) | Replays the cassette and checks the empty-then-filled row |
| [`cassettes/drum_stream.yml`](cassettes/drum_stream.yml) | The streamed Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/04-kumasi-fontomfrom-stream/drum_stream.rb
bundle exec ruby features/10-rails-integration/04-kumasi-fontomfrom-stream/drum_stream_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/04-kumasi-fontomfrom-stream/drum_stream.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
