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

Plugins can also have options. Plugin options can be local or global, with local
options taking precedence. *If a local option is specified that overrides a
global option, their results will not be merged.* In the example below, for
instance, Carol *would not* be in Assault's dont_attack configuration option.

  ---
  "irc.example.com":
    nick: katbot
    channels:
      - "#blah"
    _plugins:
      Assault:
        dont_attack:
          - Alice
          - Bob

  _plugins:
    Assault:
      dont_attack:
        - Carol
