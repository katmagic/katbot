#!/usr/bin/env ruby
require 'rss'
require 'net/http'
require 'uri'

# Parse a feed into a Hash, which will have a singleton attribute .title
# containing the title of the feed. Its keys will be article titles, and its
# values will be Strings containing the link corresponding to that title.
# Each String has a singleton attribute .date containing the date it was
# last updated.
def simple_parse_feed(feed_url)
	parsed = URI.parse(feed_url)

	con = Net::HTTP.new(parsed.host, parsed.port)
	con.use_ssl = (parsed.scheme = "https")

	feed = RSS::Parser.parse(con.get(parsed.path).body)

	res = Hash.new
	res.define_singleton_method(:title){ feed.title && feed.title.content }
	feed.items.each do |a|
		continue if not (a.title and a.title.content and a.link and a.link.href)
		
		res[a.title.content] = a.link.href
		date = a.updated.content
		a.link.href.define_singleton_method(:date){ date }
	end
	res
end
