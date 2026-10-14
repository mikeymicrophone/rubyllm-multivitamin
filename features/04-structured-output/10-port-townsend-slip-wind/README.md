# Structured output · 10 · Port Townsend slip wind

The slip watch at the Port Townsend ferry terminal streams the wind board into a schema: southwest, 18 knots, gusts 24.

**What it teaches**

- `ask` with a block streams a schema. The request sets `"stream": true`.
- Chunks are pieces of the JSON text. Joining them equals `message.content`.
- The SSE event is `response.output_text.delta`.
- `message.parsed` is the Hash. Its keys are strings. Knots and gusts are integers.

**Files**

| File | Role |
| --- | --- |
| [`slip_wind.rb`](slip_wind.rb) | Streams the wind report |
| [`slip_wind_test.rb`](slip_wind_test.rb) | Replays the cassette |
| [`cassettes/slip_wind.yml`](cassettes/slip_wind.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/10-port-townsend-slip-wind/slip_wind_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/10-port-townsend-slip-wind/slip_wind_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
