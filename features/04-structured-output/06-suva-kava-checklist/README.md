# Structured output · 06 · Suva kava checklist

The mata ni vanua in Suva turns a serving order for the Vunisa circle into a checklist. The schema hash sets `name: "KavaServingChecklist"`. Tanoa flags are booleans.

**What it teaches**

- Module functions and a fluent chat pipeline apply the plain-hash schema.
- A manual schema's `name:` is the name on `text.format`. It replaces the default `response`.
- `boolean` fields come back as `true` or `false`, not as the words yes and no.
- Steps are an array of objects, and each object sets `additionalProperties: false`.

**Files**

| File | Role |
| --- | --- |
| [`kava_checklist.rb`](kava_checklist.rb) | Asks for the serving checklist |
| [`kava_checklist_test.rb`](kava_checklist_test.rb) | Replays the cassette |
| [`cassettes/kava_checklist.yml`](cassettes/kava_checklist.yml) | Live recording of the schema turn |

**Try it**

```sh
bundle exec ruby features/04-structured-output/06-suva-kava-checklist/kava_checklist_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/06-suva-kava-checklist/kava_checklist_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
