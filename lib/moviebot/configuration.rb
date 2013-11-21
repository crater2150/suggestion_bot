# -*- encoding: utf-8 -*-
require 'xdg'
require 'moviebot/movielist'

module Moviebot

  DEFAULTS = {
    web_server: '127.0.0.1',
    name: PROJECT_NAME,
    movielist: XDG['CONFIG'].find(PROJECT_NAME + '/movies.yml') ||
      XDG['CONFIG'].to_s + ?/ + PROJECT_NAME + '/movies.yml'
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

  def self.load_configuration
    conffile = ARGV[0] || XDG['CONFIG'].find(PROJECT_NAME + '/config.yml')
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

    return config
  end

  def self.load_movie_list(file)
    if File.exist? file
      puts "YAML MOVIE LIST LOADED"
      return YAML.load_file(file)
    else
      puts "NEW MOVIE LIST"
      return MovieList.new(file)
    end
  end

end
