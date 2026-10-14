# Structured output · 06 · Neah Bay pilot checklist

The mate at Neah Bay turns a pilot order for the bulker Nordic Tidemoor into a checklist. The schema hash sets `name: "PilotBoardingChecklist"`. Ladder flags are booleans.

**What it teaches**

- A manual schema's `name:` is the name on `text.format`. It replaces the default `response`.
- `boolean` fields come back as `true` or `false`, not as the words yes and no.
- Steps are an array of objects, and each object sets `additionalProperties: false`.

**Files**

| File | Role |
| --- | --- |
| [`pilot_checklist.rb`](pilot_checklist.rb) | Asks for the boarding checklist |
| [`pilot_checklist_test.rb`](pilot_checklist_test.rb) | Replays the cassette |
| [`cassettes/pilot_checklist.yml`](cassettes/pilot_checklist.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

```sh
bundle exec ruby features/04-structured-output/06-neah-bay-pilot-checklist/pilot_checklist_test.rb
```

Re-record:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/06-neah-bay-pilot-checklist/pilot_checklist_test.rb
```

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`.
