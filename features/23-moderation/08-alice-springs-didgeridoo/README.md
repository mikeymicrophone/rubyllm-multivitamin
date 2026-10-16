# Moderation · 08 · Alice Springs didgeridoo

The rehearsal loft in Alice Springs still files last winter's didgeridoo
take as a WAV. Omni-moderation will not take audio. `moderate(with:)`
raises `UnsupportedAttachmentError` before a request is sent.

**What it teaches**

- An attachment the protocol cannot format raises
  `RubyLLM::UnsupportedAttachmentError` locally.
- The message names the MIME type (`audio/wav`).
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`didgeridoo_tape.rb`](didgeridoo_tape.rb) | Hands the WAV to omni-moderation |
| [`didgeridoo_tape_test.rb`](didgeridoo_tape_test.rb) | Checks the class and the missing cassette |
| [`rehearsal-tape.wav`](rehearsal-tape.wav) | A silent PCM tape the protocol will not send |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/08-alice-springs-didgeridoo/didgeridoo_tape.rb
bundle exec ruby features/23-moderation/08-alice-springs-didgeridoo/didgeridoo_tape_test.rb
```

No API key is required.

**Model**

`omni-moderation-latest` on OpenAI. The refusal happens before HTTP.
Checked 16 October 2026.
