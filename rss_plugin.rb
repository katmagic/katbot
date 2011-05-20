#!/usr/bin/env ruby
require 'rss'
require 'open-uri'
require 'cinch'
require_relative 'bitly/bitly'

# Parse a feed into a Hash, which will have a singleton attribute .title
# containing the title of the feed. Its keys will be article titles, and its
# values will be Strings containing the link corresponding to that title.
# Each String has a singleton attribute .date containing the date it was
# last updated.
def simple_parse_feed(feed_url)
	feed = RSS::Parser.parse(open(feed_url).read(), false)

	res = Hash.new
	res.define_singleton_method(:title){ feed.channel.title rescue feed.title }
	feed.items.each do |a|
		res[a.title] = a.link
		res[a.title].define_singleton_method(:date){ a.date }
	end
	res
end

module Cinch::Plugins
	class RSS
		include Cinch::Plugin

		DEFAULT_CONF = {
			# These all primes because we don't want feeds to end up updating at the
			# same time. Hopefully this and entropy will keep that from happening.

			# Update feeds after waiting update_interval seconds from the last update.
			'update_interval' => 283, # 13m7s
			# Delay starting a new feed for stagger_interval seconds after the last
			# feed was started. This is only used at startup.
			'stagger_interval' => 47, # 0m47s

			# This is information about your bit.ly account.
#			'bitly' => {
#				'username' => 'katmagic',
#				'api_key' => 'R_0da49e0a9118ff35f52f629d2d71bf07'
#			},

			'feeds' => []
		}

		def initialize(*a)
			super

			if config['bitly']
				@bit = BitLy.new(
					config['bitly']['username'],
					config['bitly']['api_key']
				)
			end

			Thread.start(&method(:start_queries))
		end

		# Shorten a URL only if it is longer than 30 characters, and if we have a
		# bit.ly account configured.
		def shorten(url)
			return url unless @bit
			return url if url.length < 30
			return @bit.ly(url)
		end

		private

		# Launch new threads to query feeds. This method itself should be run in a
		# new thread.
		def start_queries()
			@updated_at = Hash.new

			config['feeds'].each do |feed|
				@updated_at[feed] = (Time.now - 900)

				Thread.start do
					while true
						begin
							query_feed(feed)
						rescue Exception => ex
							bot.logger.log("Error querying #{feed}!")
							bot.logger.log_exception(ex)
						end
						sleep(config['update_interval'])
					end
				end

				sleep(config['stagger_interval'])
			end
		end

		# Tell all the channels we're in about the new things we learned from feed.
		def query_feed(feed)
			bot.debug("Querying #{feed}...")

			new_i = 0
			articles = simple_parse_feed(feed)
			articles.each do |title, url|
				if not(url.date)
					bot.debug("#{title.inspect} in #{feed} has no date! Ignoring...")
					next
				elsif url.date > @updated_at[feed]
					new_i += 1
				else
					next
				end

				bot.channels.each do |chan|
					chan.safe_msg("#{title} - #{shorten(url)} (via #{articles.title})")
				end
			end

			@updated_at[feed] = Time.now

			bot.debug("#{new_i}/#{articles.length} new in #{articles.title}.")
		end
	end
end
