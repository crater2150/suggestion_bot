# -*- encoding: utf-8 -*-
require 'xdg'
require 'suggestion_bot/suggestion_list'
require 'suggestion_bot/language'

module SuggestionBot::Config
  extend self

  DEFAULTS = {
    web_server: '127.0.0.1',
    name: SuggestionBot::PROJECT_NAME,
    suggestion_group: "suggestions",
    lang: "en"
  }

  class ConfigurationError < StandardError
    MESSAGES = {
      missing_key: "Configuration key '%s' is missing",
      file_open_error: "Configuration file could not be opened: %s",
      no_configuration: "A configuration file is needed. Place it at " +
        "#{XDG['CONFIG']} or give its path on the command line",
      syntax_error: "Configuration file malformed. Syntax error: %s"
    }
    def initialize(errtype, param)
      @errtype = errtype
      @param = param
    end

    def message
      MESSAGES[@errtype] % @param
    end
  end

  def self.load
    conffile = ARGV[0] || XDG['CONFIG'].find(SuggestionBot::PROJECT_NAME + '/config.yml')
    raise ConfigurationError.new(:no_configuration) if conffile.nil?

    begin
      config = DEFAULTS.merge YAML.load_file(conffile)
    rescue Psych::SyntaxError => e
      raise ConfigurationError.new(:syntax_error, e.message)
    rescue SystemCallError => e
      raise ConfigurationError.new(:file_open_error, e.message)
    end

    [:irc_server, :channels].each do |key|
      raise ConfigurationError.new(:missing_key, key) if config[key].nil?
    end

    configure_list_path(config)
    configure_language(config)

    return config
  end

  def configure_language(config)
    langfile = XDG['CONFIG'].find(
      "#{SuggestionBot::PROJECT_NAME}/language/#{config[:lang]}.yml"
    )

    if langfile
      SuggestionBot::Language::LANG.merge YAML.load_file(langfile)
    end
  end

  def ensure_data_dir(datafile_path)
    dirpath = File.dirname(datafile_path)
    Dir.mkdir(dirpath) unless Dir.exist? dirpath
  end

  def configure_list_path(config)
    subpath = "%s/%s.yml" % [
      SuggestionBot::PROJECT_NAME, config[:suggestion_group]
    ]

    config[:suggestion_list] =
      XDG['DATA'].find(subpath) || XDG['DATA'].to_s + ?/ + subpath

    ensure_data_dir(config[:suggestion_list])
  end

  def load_suggestion_list(file)
    if File.exist? file
      list = YAML.load_file(file)
      list.path = file
      return list
    else
      return SuggestionList.new(file)
    end
  end

end
