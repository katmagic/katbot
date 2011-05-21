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

Plugin-Specific Options
-----------------------

### Assault Plugin ###

- `dont_attack` - This is a list of nicknames that the bot will refuse to
attack. _(Default: `['katmagic']`)_

### RSS Plugin ###

- `update_interval` - Each feed begins a new update this many seconds _after_
that same feed was fetched the last time. _(Default: `283` (13m7s))_

- `stagger_interval` - This is the period (in seconds) that we will wait before starting the next RSS feed fetch loop at startup. We need this because we don't
want all of our articles to be fetched at the same time. _(Default: `47`)_

- `bitly` - This is a Hash containing information about a bit.ly account, which
is used to shorten long (over thirty characters) links. If left blank, no links
will be shortened. The Hash has the following keys:
	- `username` - This is your bit.ly username.
	- `api_key` - This is your bit.ly API key. After signing up for an account,
	your key can be found at <https://bit.ly/a/your_api_key>.

- `feeds` - This is an Array of URLs of RSS feeds. _(Default: `[]`)_
