#!/usr/bin/env ruby
require 'bundler/setup'
require 'cinch'
require_relative 'get_title'

module Cinch::Plugins
	class Title
		include Cinch::Plugin

		listen_to :channel

		def listen(msg)
			URI.extract(msg.message).each do |uri|
				uri = URI.parse(uri)
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
end

