#!/usr/bin/env ruby
require 'cinch'
require 'yaml'

def load_plugins()
	plugin_dir = File.dirname(__FILE__)

	Dir.entries(plugin_dir).grep(/_plugin\.rb$/) do |e|
		load( File.join(plugin_dir, e) )
	end
end

load_plugins()

conf = YAML.load_file( ARGV[0] || File.join(ENV['HOME']||'.', '.katbot.yml') )

bot_threads = conf.map do |servname, sc|
	# This is reserved for the configuration of plugins.
	if servname == '_plugins'
		next
	# This allows a server that's literally named '_plugins'. I don't know why
	# anyone would fuck with their DNS in this way, but it's there if you need it.
	elsif servname =~ /^_(_+plugins)$/
		servname = $1
	end

	bot = Cinch::Bot.new do
		configure do |c|
			c.nick = sc['nick']
			c.user = sc['user'] || sc['nick']
			c.real_name = sc['real_name'] || sc['nick']
			c.channels = sc['channels']
			c.server = servname
			c.ssl = sc['ssl']

			c.port = sc['port'] || (sc['ssl'] ? 6697 : 6667)

			c.plugins.plugins = Cinch::Plugins.constants.map{ |p|
				plugin = Cinch::Plugins.const_get(p)
				# Set our configuration options.
				c.plugins.options[plugin] = {}.tap do |opts|
					opts.update(plugin::DEFAULT_CONF) rescue nil
					opts.update(conf['_plugins'][p.to_s]) rescue nil
					opts.update(sc['_plugins'][p.to_s]) rescue nil
				end

				plugin
			}
		end

		on :message, '!reload' do |m|
			load_plugins()
			m.reply("Reloaded.")
		end

		on :invite do |m|
			m.channel.join()
		end
	end

	Thread.new do
		bot.start()
	end
end

bot_threads.each do |thread|
	thread.join()
end

