#!/usr/bin/env ruby
# This script sucks. I used it to fix the capitalization of animals.txt, but
# you shouldn't use it.

WORDS = open("/usr/share/dict/words").lines.grep(/^[A-Z][^']*$/).map(&:strip)
def decapitalize(s)
	s.gsub(/\b(\w+)\b/){ |w|
		w.downcase!
		WORDS.find{|_| _.downcase == w} || w
	}
end

if $PROGRAM_NAME == __FILE__
	lines = open(ARGV[0], 'r'){|_|_.lines.to_a}

	open(ARGV[0], 'w') do |out|
		lines.each do |l|
			out.write( decapitalize(l) )
		end
	end
end
