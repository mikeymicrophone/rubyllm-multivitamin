# Streaming · 13 · Cape Disappointment horn relief

The relief is taking the foghorn watch at Cape Disappointment. The blast
and the compressor are on the posted card, not in the question, so the
watch calls a tool while the answer streams. The speech starts, and the
relief stops it on the next spoken chunks.

**What it teaches**

- Tool-call chunks carry a partial argument string. One chunk can hold the
  name and an empty string. A later chunk can hold the JSON and no name.
- `before_tool_call` receives the finished call. Its `arguments` are a Hash.
  Joining the fragment strings and parsing that JSON matches the Hash. The
  tool runs from that callback path, not from a chunk.
- After the tool message is on the chat, `chat.cancel` during the spoken
  reply raises `RubyLLM::CancelledError`. The roles stop at `:tool`. The
  final assistant sentence is not appended.
- The cassette's first request names `posted_horn_card` and does not contain
  the figures the tool returns.

**Files**

| File | Role |
| --- | --- |
| [`horn_relief.rb`](horn_relief.rb) | Streams a tool call, then cancels the spoken relief |
| [`horn_relief_test.rb`](horn_relief_test.rb) | Replays the cassette and checks the fragments and the cancel |
| [`cassettes/horn_relief.yml`](cassettes/horn_relief.yml) | The tool-call stream and the spoken stream |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/13-cape-disappointment-relief/horn_relief.rb
bundle exec ruby features/02-streaming/13-cape-disappointment-relief/horn_relief_test.rb
```

Both commands replay the cassette. No API key is required.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/13-cape-disappointment-relief/horn_relief_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
