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
      cfg = SuggestionBot::Config.load
      Bot.new(cfg)
    rescue Config::ConfigurationError => e
      puts e.message
    end
  end
end
