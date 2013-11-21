#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require "moviebot/version"
require "moviebot/configuration"
require "moviebot/bot"
require "cinch"
require 'yaml'

module Moviebot

  def self.run
    begin
      cfg = Moviebot.load_configuration
      Bot.new(cfg)
    rescue ConfigurationError => e
      puts e.message
    end
  end
end
