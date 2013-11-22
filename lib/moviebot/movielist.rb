# -*- encoding: utf-8 -*-
require 'set'

module Moviebot
  # Represents a list of movies sorted by votes.
  class MovieList
    # Path for saving the list to disk
    attr_accessor :path
    
    # The movielist needs to know the path to its file, so it can automatically
    # save any changes
    def initialize(path)
      @movies = SortedSet.new
      @path = path
    end

    # return the movies as sorted set
    def list
      @movies
    end

    # Add a new movie to the list with one vote by the user who added it.
    # If the movie already exists, a vote is added.
    def add_movie(user, title)
      movie = Movie.new(title)

      if ! (existing = @movies.find {|m| m.eql? movie }).nil?
        if existing.add_vote(user)
          return :existing_voted
        else
          return :existing_already_voted
        end
      else
        @movies.add(movie)
        movie.add_vote(user)
        return :added
      end
    ensure
      save!
    end

    # Adds a vote from +user+ to a movie given either by
    # name or by index.
    #
    # The method returns a symbol indicating the result and the name of the
    # movie:
    #  +:no_such_movie+::
    #    No matching movie was found, no vote added
    #  +:voted+::
    #    The movie was found and a vote was added
    #  +:already_voted+::
    #    The movie was found, but the user already had voted
    def vote(user, movie)
      mov = find(movie)

      if mov.nil?
        :no_such_movie, movie
      else
        if mov.add_vote(user)
          return :voted, mov.name
        else
          return :already_voted, mov.name
        end
      end
    ensure
      save!
    end

    # Removes a vote from +user+ from a movie given either by name or by index.
    #
    # The method returns a symbol indicating the result and the name of the
    # movie:
    #  +:no_such_movie+::
    #    No matching movie was found, no vote removed
    #  +:unvoted+::
    #    The movie was found and a vote was removed
    #  +:no_such_vote+::
    #    The movie was found, but it had no vote from the user
    def unvote(user, movie)
      mov = find(movie)

      if mov.nil?
        :no_such_movie, movie
      else
        if mov.delete_vote(user)
          return :unvoted, mov.name
        else
          return :no_such_vote, mov.name
        end
      end
    end

    # write the movielist to disk.
    def save!
      File.write(@path, self.to_yaml)
    end

    # Ensure, that only the movie list is saved, the path to the file itself is
    # runtime information
    def to_yaml_properties
      [:@movies]
    end

    # Finds the first movie matching the given name, or the movie with the given
    # index if a numeric string or a number is given.
    # If no matching movie is found, nil is returned
    def find(movie)
      if /^\d$/.match movie.to_s or movie.is_a? Numeric
        @movies.to_a[movie.to_i]
      else
        mov = Movie.new(movie.to_s)
        @movies.find {|m| m.eql? mov }
      end
    end
  end

  class Movie
    attr_accessor :name

    def initialize(name)
      @name = name
      @votes = Set.new
    end

    def eql?(other)
      @name.downcase == other.name.downcase
    end

    def add_vote(voter)
      return false if @votes.include voter
      @votes.add voter
      return true
    end

    def delete_vote(voter)
      return false unless @votes.include voter
      @votes.delete voter
      return true
    end

    def votes
      @votes.count
    end

    def to_s

    end

    def to_formatted_s
      "%s [%d Votes]" % [ @name, votes ]
    end

    def <=>(other)
      votes <=> other.votes
    end
  end
end
