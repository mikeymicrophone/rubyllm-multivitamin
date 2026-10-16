# Image generation · 13 · Sarajevo anvil handover

The outgoing smith on Kazandžiluk paints the anvil table, saves the
plate, and asks the relief whether the plate is in hand. `ask` takes the
saved path with `with:`.

**What it teaches**

- `RubyLLM.paint`, then `save`, then `chat.ask` with `with:` the saved path.
- The attachment rides as `input_image` on OpenAI's Responses API.
- Live `b64_json` is megabytes. After `save`, the script writes the catalog's
  1×1 PNG stand-in so the chat request stays small and matches replay. The
  cassette helper shrinks the paint response the same way.
- Roles are `system`, `user`, `assistant`. The relief names Kazandžiluk.

**Files**

| File | Role |
| --- | --- |
| [`anvil_handover.rb`](anvil_handover.rb) | Paints, saves, and asks about the plate |
| [`anvil_handover_test.rb`](anvil_handover_test.rb) | Replays the cassette |
| [`cassettes/anvil_handover.yml`](cassettes/anvil_handover.yml) | Live OpenAI paint plus chat |

**Try it**

```sh
bundle exec ruby features/07-image-generation/13-sarajevo-anvil-handover/anvil_handover_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Paint: `gpt-image-1-mini`. Chat: `gpt-4.1-mini`.
