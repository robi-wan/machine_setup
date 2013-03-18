# encoding: UTF-8

module SetupConfiguration

  module Translation

    FILE_EXTENSION='setup.param'.freeze

    def self.translation_file(config_name, lang)
      "#{config_name}.#{FILE_EXTENSION}.#{lang}.yml"
    end

    def self.translation_files(config_name)
      languages.collect { |lang| translation_file(config_name, lang) }
    end

    # Returns all supported setup languages.
    def self.languages()
      language_defs().keys()
    end

    def self.language_name(lang)
      language_defs()[lang]
    end

    def self.language_abbreviation(lang_name)
      language_defs.invert()[lang_name.downcase]
    end

    def self.language_names()
      language_defs.values.sort
    end

    private
    
    def self.language_defs()
      {:de => 'deutsch', :en => 'english'}
    end

    class Translator
      include SetupConfiguration::Encoder

      NAME = :name.freeze
      COMMENT = :comment.freeze
      EMPTY = ''

      # Adds a file with translations.
      def self.i18n_load_path(path)
        I18n.load_path << path
      end

      # Returns name and description for the given parameter in the given language.
      def translate(key, language)
        name=I18n.translate(NAME, :scope => key, :default => key.to_s, :locale => language)
        description=I18n.translate(COMMENT, :scope => key, :default => EMPTY, :locale => language)
        # if an empty string is found as translation use key as name (not empty string)
        name = key.to_s if name.strip.empty?
        description = EMPTY if description.strip.empty?
        name = force_encoding(name)
        description = force_encoding(description)
        [name, description]
      end

    end

  end

end
