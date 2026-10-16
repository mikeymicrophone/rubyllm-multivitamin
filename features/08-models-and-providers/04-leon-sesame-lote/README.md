# Models and providers · 04 · León sesame lote assume exists

The lote clerk at a León sesame house tries to put an unlisted clerk on
the radio without naming the channel, then names OpenAI, then asks
whether lote Ajonjolí Norte can go to roaster 2.

**What it teaches**

- `assume_model_exists: true` without `provider:` raises `ArgumentError`
  (`Provider must be specified if assume_model_exists is true`).
- A slug the registry lacks becomes a synthetic `RubyLLM::Model`:
  capabilities `function_calling`, `streaming`, `vision`,
  `structured_output`; `metadata[:warning]` explains they may not be
  accurate; `supports?(:reasoning)` is false; `context_window` is nil.
- A slug `find` already knows keeps its registry entry. Assume does not
  replace the window or the capabilities.
- The roaster question still goes out on `gpt-4.1-mini`.

**Files**

| File | Role |
| --- | --- |
| [`lote_clerk.rb`](lote_clerk.rb) | ArgumentError, synthetic model, listed model, one ask |
| [`lote_clerk_test.rb`](lote_clerk_test.rb) | Replays the cassette and checks all four steps |
| [`cassettes/lote_clerk.yml`](cassettes/lote_clerk.yml) | One Responses round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/04-leon-sesame-lote/lote_clerk.rb
bundle exec ruby features/08-models-and-providers/04-leon-sesame-lote/lote_clerk_test.rb
```

Both commands replay the cassette. No API key is required. Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/08-models-and-providers/04-leon-sesame-lote/lote_clerk_test.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap allows.
Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered the probe but inverted
the 11.2 / 12.0 moisture comparison. Fallback:
`nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`.
