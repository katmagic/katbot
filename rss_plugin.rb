#!/usr/bin/env ruby
require 'rss'
require 'open-uri'

# Parse a feed into a Hash, which will have a singleton attribute .title
# containing the title of the feed. Its keys will be article titles, and its
# values will be Strings containing the link corresponding to that title.
# Each String has a singleton attribute .date containing the date it was
# last updated.
def simple_parse_feed(feed_url)
	feed = RSS::Parser.parse(open(feed_url).read(), false)

	res = Hash.new
	res.define_singleton_method(:title){ feed.channel.title }
	feed.items.each do |a|
		res[a.title] = a.link
		res[a.title].define_singleton_method(:date){ a.date }
	end
	res
end
