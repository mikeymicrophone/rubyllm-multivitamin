# frozen_string_literal: true

# Multimodal attachments · 10 · Port Townsend slip wind
#
# Teaches:
# - convert_unsupported_attachments turns a spreadsheet into a text
#   attachment before the request.
# - The user message keeps the original workbook.
# - The wire carries the replacement text, wrapped as a file element,
#   and does not carry the xlsx bytes.

require "logger"
require "stringio"
require "zlib"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendWindBook
  # Chat Completions cannot send the wind book. The slip clerk reads the
  # sheet and hands the model a text attachment instead.
  class WindBook
    def self.plain_text(attachment)
      rows = Sheet.rows(attachment.content)
      _header, *body = rows
      lines = body.map do |slip, gust, direction, clock|
        "#{slip}, gust #{gust} knots, direction #{direction} degrees, clock #{clock}."
      end
      (["Port Townsend ferry slip wind book."] + lines).join("\n")
    end
  end

  # Reads the one sheet this catalog writes. ZIP uses raw deflate.
  class Sheet
    def self.rows(bytes)
      files = entries(bytes)
      strings = files.fetch("xl/sharedStrings.xml").scan(%r{<t[^>]*>(.*?)</t>}m).flatten
      strings = strings.map { |text| text.gsub("&amp;", "&").gsub("&lt;", "<").gsub("&gt;", ">") }
      files.fetch("xl/worksheets/sheet1.xml").split("<row").drop(1).map do |row|
        row.scan(%r{<v>(\d+)</v>}).flatten.map { |id| strings.fetch(id.to_i) }
      end
    end

    def self.entries(bytes)
      io = StringIO.new(bytes)
      files = {}
      until io.eof?
        signature = io.read(4)
        break if signature.nil? || signature != "PK\x03\x04"

        _version, _flag, method, _time, _date, _crc, compressed, _plain, name_len, extra_len =
          io.read(26).unpack("vvvvvVVVvv")
        name = io.read(name_len)
        io.read(extra_len)
        data = io.read(compressed)
        files[name] = method.zero? ? data : Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(data)
      end
      files
    end
  end

  class SlipWind
    BOOK = File.expand_path("slip-wind.xlsx", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the slip watch at the Port Townsend ferry landing.
      Answer in one sentence from the wind book text.
      Include the slip, the gust in knots, the direction, and the clock time.
      Do not invent a figure.
    TEXT

    WIND_QUESTION = "What gust did the north float record, from which direction, and at what clock time?"

    Result = Struct.new(
      :reading,
      :replacement,
      :kept_name,
      :kept_type,
      :finish,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      replacement = nil
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.convert_unsupported_attachments do |attachment|
        next unless attachment.document?

        text = WindBook.plain_text(attachment)
        replacement = RubyLLM::Attachment.new(StringIO.new(text), filename: "slip-wind.txt")
      end
      reading = chat.ask(WIND_QUESTION, with: BOOK)
      kept = chat.messages.find { |message| message.role == :user }.attachments.first

      Result.new(
        reading: reading.content,
        replacement: replacement&.content,
        kept_name: kept.filename,
        kept_type: kept.type,
        finish: reading.finish_reason,
        cost: reading.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(
        model: Multivitamin::Models::OPENAI_CHAT,
        provider: :openai,
        protocol: :chat_completions
      )
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "slip_wind") do
    result = PortTownsendWindBook::SlipWind.conduct
  end

  puts result.reading
end
