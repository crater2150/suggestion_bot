# -*- encoding: utf-8 -*-
module SuggestionBot::Language
  LANG = {
    usage: "I know these commands:\n" +
           "!suggest <title>\n" +
           "  Add a new suggestion.\n" +
           "  If it already exist, I'll count that as a vote for it.\n" +
           "!vote <title or number>\n" +
           "  Vote for a suggestion\n" +
           "!unvote <title oder number>\n" +
           "  Withdraw your vote for a suggestion\n" +
           "!list\n" +
           "  Show all suggestion sorted by number of votes\n",
    replies: {
      existing_voted:
      "\"%s\" has already been suggested, I'll count that as a vote.",
      existing_already_voted:
      "\"%s\" has already been suggested and you already voted for it.",
      added:
      "\"%s\" has been added.",
      no_such_suggestion:
      "I don't know about \"%s\".",
      voted:
      "Your vote for \"%s\" was counted",
      already_voted:
      "You already voted for \"%s\"",
      unvoted:
      "You withdrew your vote for \"%s\"",
      no_such_vote:
      "You have not voted for \"%s\"",
      no_suggestions:
      "No suggestions yet. Use !suggest to add one."
    }
  }

end
