# -*- encoding: utf-8 -*-
require 'cinch'
require 'moviebot/configuration'

class Moviebot::Bot
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
    no_such_movie:
      "Ich kenne \"%s\" nicht.",
    voted:
      "Deine Stimme für \"%s\" wurde gezählt",
    already_voted:
      "Du hast bereits für \"%s\" gestimmt",
    unvoted:
      "Deine Stimme für \"%s\" wurde zurückgenommen",
    no_such_vote:
      "Du hast nicht für \"%s\" gestimmt",
    no_movies:
      "Noch keine Vorschläge"
  }

  def initialize(config)
    movies = Moviebot.load_movie_list config[:movielist]

    @bot = Cinch::Bot.new do
      configure do |c|
        c.server   = config[:irc_server]
        c.nick     = config[:name]
        c.channels = config[:channels]
      end


      on :message, /!suggest (.*)/ do |m, movie|
        message = movies.add_movie(m.user.nick, movie)
        m.reply(REPLIES[message] % movie)
      end

      on :message, /!vote (.*)/ do |m, movie|
        message, name = movies.vote(m.user.nick, movie)
        m.reply(REPLIES[message] % name)
      end

      on :message, /!unvote (.*)/ do |m, movie|
        message, name = movies.unvote(m.user.nick, movie)
        m.reply(REPLIES[message] % name)
      end

      on :message, /!list/ do |m|
        ranking = movies.list(m)

        if ranking.empty?
          m.reply REPLIES[:no_movies]
        else
          ranking.each_with_index do |movie,index|
            m.reply ("(%2d)  " % index) +  movie.to_formatted_s
          end
        end
      end

      on :message, /!help/ do |m|
        m.reply USAGE
      end
    end

    @bot.start
  end
end
