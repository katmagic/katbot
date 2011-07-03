require_relative 'get_title'

class Cinch::Plugins::Title
	include Cinch::Plugin

	listen_to :channel

	def listen(msg)
		URI.extract(msg.message).each do |uri|
			begin
				uri = URI.parse(uri)
			rescue URI::InvalidURIError
				# Apparently URI.extract will occasionally extract invalid URIs.
				next
			end
			bot.debug("Getting title of #{uri}")

			begin
				title = get_title(uri)
				msg.safe_reply("#{uri} - #{title}")
			rescue SocketError
				msg.safe_reply("#{uri.host} doesn't seem to be up.")
			rescue TypeError
			end
		end
	end
end

