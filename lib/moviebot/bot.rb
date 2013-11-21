# -*- encoding: utf-8 -*-
require 'cinch'
require 'moviebot/configuration'

class Moviebot::Bot
  USAGE = <<-HELP
Folgende Befehle kenne ich:
 !suggest <filmtitel>
     Schlage einen Film vor. Existiert er schon zähle ich das als Stimme.
 !vote <filmtitel oder nummer>
     Stimme für einen Film
 !list
     Zeige die Filme sortiert nach Anzahl Stimmen an
  HELP

  def initialize(config)
    movies = Moviebot.load_movie_list config[:movielist]

    @bot = Cinch::Bot.new do
      configure do |c|
        c.server   = config[:irc_server]
        c.nick     = config[:name]
        c.channels = config[:channels]
      end


      on :message, /!suggest (.*)/ do |m, movie|
        movies.add_movie(m, movie)
      end

      on :message, /!vote (.*)/ do |m, movie|
        movies.vote(m, movie)
      end

      on :message, /!list/ do |m|
        movies.list(m)
      end

      on :message, /!help/ do |m|
        m.reply USAGE
      end
    end

    @bot.start
  end
end
