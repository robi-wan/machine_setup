# encoding: UTF-8

module SetupConfiguration

  module Encoder

    @@supported = RUBY_VERSION > '1.9'

    def self.encoding_supported
      @@supported
    end

    def self.default_encoding
      'windows-1252'
    end

    def self.encoding
      default_encoding
    end

    if encoding_supported
      Encoding.default_external = encoding
#      puts "Encoding.default_external: #{Encoding.default_external}"
#      puts Encoding.default_internal
    end

    def force_encoding(text, encoding = Encoder.encoding)
      if @@supported
        text.force_encoding(encoding)
      else
        text
      end
    end

  end
end
