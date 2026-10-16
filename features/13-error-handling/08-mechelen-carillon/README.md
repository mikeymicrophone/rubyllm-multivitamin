# Error handling · 08 · Mechelen carillon

The practice loft at Mechelen's carillon school still files last
winter's rehearsal as a WAV. `gpt-4.1-mini` on the Responses API will
not take audio. `ask` raises `UnsupportedAttachmentError` before a
request is sent. `request_shape` is nil.

**What it teaches**

- An attachment the protocol cannot format raises
  `RubyLLM::UnsupportedAttachmentError` locally.
- `response` is nil. `request_shape` is nil.
- The message names the MIME type (`audio/wav`).
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`carillon_tape.rb`](carillon_tape.rb) | Hands the WAV to `gpt-4.1-mini` |
| [`carillon_tape_test.rb`](carillon_tape_test.rb) | Checks the class and the nil shape |
| [`carillon-tape.wav`](carillon-tape.wav) | A silent PCM tape the protocol will not send |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/08-mechelen-carillon/carillon_tape.rb
bundle exec ruby features/13-error-handling/08-mechelen-carillon/carillon_tape_test.rb
```

No API key is required.

**Model**

`gpt-4.1-mini` on OpenAI's Responses API. The refusal happens before
HTTP. Checked 16 October 2026.
