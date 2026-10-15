# Error handling · 08 · Slip Point unsupported tape

The horn house at Slip Point, above Clallam Bay, still files last
winter's diaphone recording as a WAV. `gpt-4.1-mini` on the Responses
API will not take audio. `ask` raises `UnsupportedAttachmentError`
before a request is sent. `request_shape` is nil.

**What it teaches**

- An attachment the protocol cannot format raises
  `RubyLLM::UnsupportedAttachmentError` locally.
- `response` is nil. `request_shape` is nil.
- The message names the MIME type (`audio/wav`).
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`unsupported_tape.rb`](unsupported_tape.rb) | Hands the WAV to `gpt-4.1-mini` |
| [`unsupported_tape_test.rb`](unsupported_tape_test.rb) | Checks the class and the nil shape |
| [`diaphone-tape.wav`](diaphone-tape.wav) | A silent PCM tape the protocol will not send |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/08-slip-point-unsupported-tape/unsupported_tape.rb
bundle exec ruby features/13-error-handling/08-slip-point-unsupported-tape/unsupported_tape_test.rb
```

No API key is required.

**Model**

`gpt-4.1-mini` on OpenAI's Responses API. The refusal happens before
HTTP. Checked 15 October 2026.
