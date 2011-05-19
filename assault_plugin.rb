#!/usr/bin/env ruby
# This is a rather silly script that will assault people on command.

require 'cinch'

LOCAL_DIR = File.absolute_path( File.dirname(__FILE__) )
def LOCAL_DIR.+(file)
	File.join(self, file)
end

module Cinch::Plugins
	class Assault
		ANIMALS = open(LOCAL_DIR + 'animals.txt').lines.map(&:strip)
		ASSAULT_METHODS = open(LOCAL_DIR + 'assault_methods.txt').lines.map(&:strip)
		
		include Cinch::Plugin
		
		match /assault (\S+)/, method: :assault
		
		def assault(m, victim)
			assault_method = ASSAULT_METHODS[ rand(ASSAULT_METHODS.length) ]
			animal = ANIMALS[ rand(ANIMALS.length) ]
			an = (animal =~ /^[aeiou]/i) ? 'an' : 'a'
			m.channel.safe_action("#{assault_method} #{victim} with #{an} #{animal}.")
		end
	end
end
