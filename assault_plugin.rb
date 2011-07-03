# This is a rather silly script that will assault people on command.
# It takes one option, 'dont_attack', which is an Array of nicknames not to
# assault.

LOCAL_DIR = File.absolute_path( File.dirname(__FILE__) )
def LOCAL_DIR.+(file)
	File.join(self, file)
end

class Cinch::Plugins::Assault
	ANIMALS = open(LOCAL_DIR + 'animals.txt').lines.map(&:strip)
	ASSAULT_METHODS = open(LOCAL_DIR + 'assault_methods.txt').lines.map(&:strip)

	DEFAULT_CONF = {
		'dont_attack' => [
			'katmagic'
		]
	}

	include Cinch::Plugin

	match /assault (.*)/, method: :assault

	def assault(m, victim)
		if not m.channel.has_user?(victim)
			m.safe_reply("I couldn't seem to find #{victim}.")
			return
		elsif config['dont_attack'].include?(victim)
			m.safe_reply("I couldn't possibly attack #{victim}!")

			# Retaliate.
			return if config['dont_attack'].include?(m.user)
			victim = m.user
		end

		assault_method = ASSAULT_METHODS[ rand(ASSAULT_METHODS.length) ]
		animal = ANIMALS[ rand(ANIMALS.length) ]
		an = (animal =~ /^[aeiou]/i) ? 'an' : 'a'
		m.channel.safe_action("#{assault_method} #{victim} with #{an} #{animal}.")
	end
end
