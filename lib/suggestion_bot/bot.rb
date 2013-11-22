# -*- encoding: utf-8 -*-
require 'cinch'
require 'suggestion_bot/configuration'

class SuggestionBot::Bot
  USAGE = <<-HELP
Folgende Befehle kenne ich:
 !suggest <titel>
     Füge einen neuen Vorschlag hinzu.
     Existiert er schon zähle ich das als Stimme.
 !vote <titel oder nummer>
     Stimme für einen Vorschlag
 !unvote <titel oder nummer>
     Nimm eine Stimme zurück
 !list
     Zeige die Vorschläge sortiert nach Anzahl Stimmen an
  HELP

  REPLIES = {
    existing_voted:
      "\"%s\" wurde schon vorgeschlagen, ich zähle das als Stimme dafür",
    existing_already_voted:
      "\"%s\" wurde schon vorgeschlagen und du hast bereits dafür gestimmt",
    added:
      "\"%s\" wurde hinzugefügt",
    no_such_suggestion:
      "Ich kenne \"%s\" nicht.",
    voted:
      "Deine Stimme für \"%s\" wurde gezählt",
    already_voted:
      "Du hast bereits für \"%s\" gestimmt",
    unvoted:
      "Deine Stimme für \"%s\" wurde zurückgenommen",
    no_such_vote:
      "Du hast nicht für \"%s\" gestimmt",
    no_suggestions:
      "Noch keine Vorschläge"
  }

  def initialize(config)
    suggestions = SuggestionBot.load_suggestion_list config[:suggestion_list]

    @bot = Cinch::Bot.new do
      configure do |c|
        c.server   = config[:irc_server]
        c.nick     = config[:name]
        c.channels = config[:channels]
      end

      prefix = if config.has_key? :command_prefix
                 config[:command_prefix] + \_
               end

      on :message, /!#{prefix}suggest (.*)/ do |m, suggestion|
        message = suggestions.add_suggestion(m.user.nick, suggestion)
        m.reply(REPLIES[message] % suggestion)
      end

      on :message, /!#{prefix}vote (.*)/ do |m, suggestion|
        message, name = suggestions.vote(m.user.nick, suggestion)
        m.reply(REPLIES[message] % name)
      end

      on :message, /!#{prefix}unvote (.*)/ do |m, suggestion|
        message, name = suggestions.unvote(m.user.nick, suggestion)
        m.reply(REPLIES[message] % name)
      end

      on :message, /!#{prefix}list/ do |m|
        ranking = suggestions.list

        if ranking.empty?
          m.reply REPLIES[:no_suggestions]
        else
          ranking.each_with_index do |suggestion,index|
            m.reply ("(%2d)  " % index) +  suggestion.to_formatted_s
          end
        end
      end

      on :message, /!#{prefix}help/ do |m|
        m.reply USAGE
      end

      on :message, /!#{prefix}quit/ do |m|
        quit
      end
    end

    @bot.start
  end
end
