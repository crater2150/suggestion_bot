#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require "suggestion_bot/version"
require "suggestion_bot/configuration"
require "suggestion_bot/bot"
require "cinch"
require 'yaml'

module SuggestionBot

  def self.run
    begin
      cfg = SuggestionBot.load_configuration
      Bot.new(cfg)
    rescue ConfigurationError => e
      puts e.message
    end
  end
end
