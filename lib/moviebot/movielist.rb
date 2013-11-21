# -*- encoding: utf-8 -*-
require 'set'

module Moviebot
  class MovieList
    attr_accessor :path
    def initialize(path)
      @movies = SortedSet.new
      @path = path
    end

    def list(m)
      if @movies.empty?
        m.reply "Noch keine Filme vorgeschlagen"
        return
      end

      @movies.each_with_index do |movie,index|
        m.reply ("(%2d)  " % index) +  movie.to_s
      end
    end

    def add_movie(m, title)
      movie = Movie.new(title)

      unless (existing = @movies.find {|m| m.eql? movie }).nil?
        m.reply "\"#{title}\" wurde schon vorgeschlagen, ich zähle das als Stimme dafür"
        existing.add_vote(m.user.nick)
      else
        m.reply "\"#{title}\" wurde hinzugefügt"
        @movies.add(movie)
        movie.add_vote(m.user.nick)
      end
      save!
    end

    def vote(m, movie)
      if /^\d$/.match movie
        mov = @movies.to_a[movie.to_i]
      else
        mov = @movies.find {|m| m.eql? mov }
      end

      if mov.nil?
        m.reply "Diesen Film kenne ich nicht"
      else
        mov.add_vote(m.user.nick)
        m.reply "Deine Stimme für #{mov.name} wurde gezählt"
      end
      save!
    end

    def save!
      File.write(@path, self.to_yaml)
    end

    def to_yaml_properties
      [:@movies]
    end
  end

  class Movie
    attr_accessor :name

    def initialize(name)
      @name = name
      @votes = Set.new
    end

    def eql?(other)
      @name == other.name
    end

    def add_vote(voter)
      @votes.add voter
    end

    def delete_vote(voter)
      @votes.delete voter
    end

    def votes
      @votes.count
    end

    def to_s
      "%s [%d Votes]" % [ @name, votes ]
    end

    def <=>(other)
      votes <=> other.votes
    end
  end
end
