# Moderation · 06 · Guadalajara jarabe studio

The studio clerk in Guadalajara puts last winter's moderation pin on a
`RubyLLM.context` so the jarabe card uses that id without passing
`model:` on the call. The global default stays `omni-moderation-latest`.
Bedrock guardrails need AWS this catalog does not have.

**What it teaches**

- `default_moderation_model` on a context selects the pinned id.
- The global default is unchanged after the call.
- The cassette body names the pinned id.

**Files**

| File | Role |
| --- | --- |
| [`jarabe_context.rb`](jarabe_context.rb) | Screens the card through a context pin |
| [`jarabe_context_test.rb`](jarabe_context_test.rb) | Checks the pin and the global default |
| [`cassettes/jarabe_context.yml`](cassettes/jarabe_context.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/06-guadalajara-jarabe-studio/jarabe_context.rb
bundle exec ruby features/23-moderation/06-guadalajara-jarabe-studio/jarabe_context_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/06-guadalajara-jarabe-studio/jarabe_context.rb
```

**Model**

`omni-moderation-2024-09-26` on a context. Checked 16 October 2026.
