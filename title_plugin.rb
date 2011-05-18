#!/usr/bin/env ruby
require 'cinch'
require 'nokogiri'
require 'net/http'
require 'uri'

module Cinch::Plugins
	class Title
		include Cinch::Plugin

		listen_to :channel

		def listen(msg)
			URI.extract(msg.message).each do |uri|
				uri = URI.parse(uri)

				begin
					title = get_title(uri)
					msg.reply("#{uri}: #{title}")
				rescue SocketError
					msg.reply("#{uri.host} doesn't seem to be up.")
				rescue TypeError
				end
			end
		end

		private

		# Fetch the title of a URI, raising TypeError if the URL does not point to
		# an HTML document, or SocketError if the host can't be found.
		def get_title(uri)
			c = Net::HTTP.new(uri.host, uri.port)
			c.use_ssl = (uri.scheme == 'https')

			raise TypeError unless c.head(uri.request_uri).content_type == 'text/html'

			if title = Nokogiri.parse( c.get(uri.request_uri).body ).xpath('//title')
				return title.text
			else
				return nil
			end
		end
	end
end

