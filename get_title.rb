#!/usr/bin/env ruby
require 'nokogiri'
require 'net/http'
require 'uri'

# Fetch the title of a URI, raising TypeError if the URL does not point to
# an HTML document, or SocketError if the host can't be found.
def get_title(uri)
	c = Net::HTTP.new(uri.host, uri.port)
	c.use_ssl = (uri.scheme == 'https')

	raise TypeError unless c.head(uri.request_uri).content_type == 'text/html'

	if title = Nokogiri.parse( c.get(uri.request_uri).body ).xpath('//title')
		return title.text.gsub(/\s+/, ' ').strip()
	else
		return nil
	end
end
