# Suggestion Bot

A simple IRC bot for voting on suggestions.

## Installation

You can install it via rubygems:

    $ gem install suggestion_bot

## Usage

Create a config file at `$XDG_CONFIG_HOME/suggestion_bot/config.yml`:

```
---
:irc_server: your.server.address
:name: theBotsName
:suggestion_group: my_poll
:channels:
- ! '#my_awesome_channel'

```

This will make the bot join the channel `#my_awesome_channel` on the irc server
`your.server.address`. It will then use
`$XDG_DATA_HOME/suggestion_bot/my_poll.yml` for saving the suggestions and
votes, this way you can have multiple instances with different polls.

You can then start the bot with

    $ suggestion_bot

If you want to use more than one bot, you can set the config file to use from
command line:

    $ suggestion_bot /path/to/another_config.yml

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
