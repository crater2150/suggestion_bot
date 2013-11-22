# -*- encoding: utf-8 -*-
require 'cinch'
require 'suggestion_bot/configuration'
require 'suggestion_bot/language'

class SuggestionBot::Bot
  include SuggestionBot::Config
  include SuggestionBot::Language

  def initialize(config)
    suggestions = load_suggestion_list config[:suggestion_list]

    @bot = Cinch::Bot.new do
      configure do |c|
        c.server   = config[:irc_server]
        c.nick     = config[:name]
        c.channels = config[:channels]
      end

      prefix = if config.has_key? :command_prefix
                 config[:command_prefix] + ?_
               end

      on :message, /!#{prefix}suggest (.*)/ do |m, suggestion|
        message = suggestions.add_suggestion(m.user.nick, suggestion)
        m.reply(LANG[:replies][message] % suggestion)
      end

      on :message, /!#{prefix}vote (.*)/ do |m, suggestion|
        message, name = suggestions.vote(m.user.nick, suggestion)
        m.reply(LANG[:replies][message] % name)
      end

      on :message, /!#{prefix}unvote (.*)/ do |m, suggestion|
        message, name = suggestions.unvote(m.user.nick, suggestion)
        m.reply(LANG[:replies][message] % name)
      end

      on :message, /!#{prefix}list/ do |m|
        ranking = suggestions.list

        if ranking.empty?
          m.reply LANG[:replies][:no_suggestions]
        else
          ranking.each_with_index do |suggestion,index|
            m.reply ("(%2d)  " % index) +  suggestion.to_formatted_s
          end
        end
      end

      on :message, /!#{prefix}help/ do |m|
        m.reply LANG[:usage]
      end

      on :message, /!#{prefix}quit/ do |m|
        bot.quit
      end

      trap "SIGINT" do
        bot.quit
      end
    end

    @bot.start
  end
end
