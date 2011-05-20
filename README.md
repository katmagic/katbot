KatBot
======

KatBot will run a bot with after loading all the plugins in files in its root
directory ending with `_plugin.rb`.

Configuration
-------------

KatBot's configuration file is stored in `~/.katbot.yml`. The following example
should explain.

  ---
  "irc.example.com":
    nick: katbot
    ssl: true
    channels:
    - "#test-katbot"

  "irc.example.org":
    nick: katbot
    ssl: true
    channels:
    - "#test-katbot2"

