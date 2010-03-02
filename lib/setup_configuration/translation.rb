# encoding: utf-8

module SetupConfiguration::Translation

  FILE_EXTENSION="setup.param".freeze

  def self.translation_files(config_name)
    languages.collect{ |lang| "#{config_name}.#{FILE_EXTENSION}.#{lang}.yml"}
  end

  # Returns all supported setup languages.
  def self.languages()
    language_names().keys()
  end

  def self.language_name(lang)
    language_names()[lang]
  end

  def self.language_abbreviation(lang_name)
    language_names.invert()[lang_name.downcase]
  end

  def self.language_names()
    {:de => "deutsch", :en => "english"}
  end

  class Translator

    # Adds a file with translations.
    def self.i18n_load_path(path)
      I18n.load_path << path
    end

    # Returns name and description for the given parameter in the given language.
    def translate(key, language)
      name=I18n.translate(:name, :scope => key,  :default => key.to_s , :locale => language)
      description=I18n.translate(:comment, :scope => key,  :default => "", :locale => language)
      [name, description]
    end

  end

end
