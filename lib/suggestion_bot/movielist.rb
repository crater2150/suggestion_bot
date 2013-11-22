# -*- encoding: utf-8 -*-
require 'set'

module SuggestionBot
  # Represents a list of suggestions sorted by votes.
  class SuggestionList
    # Path for saving the list to disk
    attr_accessor :path
    
    # The suggestion list needs to know the path to its file, so it can
    # automatically save any changes
    def initialize(path)
      @suggestions = SortedSet.new
      @path = path
    end

    # return the suggestions as sorted set
    def list
      @suggestions
    end

    # Add a new suggestion to the list with one vote by the user who added it.
    # If the suggestion already exists, a vote is added.
    def add_suggestion(user, title)
      suggestion = Suggestion.new(title)

      if ! (existing = @suggestions.find {|s| s.eql? suggestions }).nil?
        if existing.add_vote(user)
          return :existing_voted
        else
          return :existing_already_voted
        end
      else
        @suggestions.add(suggestion)
        suggestion.add_vote(user)
        return :added
      end
    ensure
      save!
    end

    # Adds a vote from +user+ to a suggestion given either by
    # name or by index.
    #
    # The method returns a symbol indicating the result and the name of the
    # suggestion:
    #  +:no_such_suggestion+::
    #    No matching suggestion was found, no vote added
    #  +:voted+::
    #    The suggestion was found and a vote was added
    #  +:already_voted+::
    #    The suggestion was found, but the user already had voted
    def vote(user, suggestion)
      sug = find(suggestion)

      if sug.nil?
        :no_such_suggestion, suggestion
      else
        if sug.add_vote(user)
          return :voted, sug.name
        else
          return :already_voted, sug.name
        end
      end
    ensure
      save!
    end

    # Removes a vote from +user+ from a suggestion given either by name or by index.
    #
    # The method returns a symbol indicating the result and the name of the
    # suggestion:
    #  +:no_such_suggestion+::
    #    No matching suggestion was found, no vote removed
    #  +:unvoted+::
    #    The suggestion was found and a vote was removed
    #  +:no_such_vote+::
    #    The suggestion was found, but it had no vote from the user
    def unvote(user, suggestion)
      sug = find(suggestion)

      if sug.nil?
        :no_such_suggestion, suggestion
      else
        if sug.delete_vote(user)
          return :unvoted, sug.name
        else
          return :no_such_vote, sug.name
        end
      end
    end

    # write the suggestion list to disk.
    def save!
      File.write(@path, self.to_yaml)
    end

    # Ensure, that only the suggestion list is saved, the path to the file itself is
    # runtime information
    def to_yaml_properties
      [:@suggestions]
    end

    # Finds the first suggestion matching the given name, or the suggestion with the given
    # index if a numeric string or a number is given.
    # If no matching suggestion is found, nil is returned
    def find(suggestion)
      if /^\d$/.match suggestion.to_s or suggestion.is_a? Numeric
        @suggestions.to_a[suggestion.to_i]
      else
        sug = Suggestion.new(suggestion.to_s)
        @suggestions.find {|m| m.eql? sug }
      end
    end
  end

  class Suggestion
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
