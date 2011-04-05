#!/usr/bin/env ruby
require 'cinch'
require 'yaml'


def load_plugins
	plugin_dir = File.dirname(__FILE__)

	Dir.entries(plugin_dir).grep(/_plugin\.rb$/) do |e|
		load( File.join(plugin_dir, e) )
	end
end

load_plugins()

conf = YAML.load_file( ARGV[0] || File.join(ENV['HOME']||'.', '.katbot.yml') )
bot_threads = conf.map do |servname, sc|
	bot = Cinch::Bot.new do
		configure do |c|
			c.nick = sc['nick']
			c.user = sc['user'] || sc['nick']
			c.real_name = sc['real_name'] || sc['nick']
			c.channels = sc['channels']
			c.server = servname
			c.ssl = sc['ssl']

			c.port = sc['port'] || (sc['ssl'] ? 6697 : 6667)

			c.plugins.plugins = Cinch::Plugins.constants.map{ |c|
				Cinch::Plugins.const_get(c)
			}
		end

		on :message, '!reload' do |m|
			load_plugins()
			m.reply("Reloaded.")
		end
	end

	Thread.new do
		bot.start()
	end
end

bot_threads.each do |thread|
	thread.join()
end

