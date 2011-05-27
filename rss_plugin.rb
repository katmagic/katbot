#!/usr/bin/env ruby
require 'bundler/setup'
require 'rss'
require 'open-uri'
require 'cinch'
require 'bitly'

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

			@threads = Hash.new
		end
		
		listen_to :connect, method: :reload

		# Shorten a URL only if it is longer than 30 characters, and if we have a
		# bit.ly account configured.
		def shorten(url)
			return url unless @bit
			return url if url.length < 30
			return @bit.ly(url)
		end

		# Call auto_terminating_feed_loop() for every feed in our configuration.
		def reload(ev=nil)
			if config['bitly']
				@bit = BitLy.new(
					config['bitly']['username'],
					config['bitly']['api_key']
				)
			else
				@bit = nil
			end

			Thread.new do
				config['feeds'].each do |f|
					if f.is_a?(String)
						unique_auto_terminating_feed_loop(f)
					else
						unique_auto_terminating_feed_loop(f['url'])
					end

					sleep(config['stagger_interval'])
				end
			end
		end

		private

		# Start a loop that fetches a feed so long as it remains in our
		# configuration, with whatever options are determined in our configuration
		# at that time. If there's already a loop fetching this feed, do nothing.
		# This method executes in a new Thread.
		def unique_auto_terminating_feed_loop(feed)
			if @threads[feed] and @threads[feed].alive?
				bot.debug("Not starting another fetch thread for #{feed}.")
				return
			else
				@threads[feed] = Thread.new do
					bot.debug("Starting fetch thread for #{feed}.")

					last_fetched = Time.now

					while feed_info = get_feed(feed)
						fetch_feed(feed_info, last_fetched)
						last_fetched = Time.now
						sleep(feed_info['update_interval'])
					end

					bot.debug("Stopping updates of #{feed}.")
				end
			end
		end

		# Get a Hash with the following keys:
		#   - url: the URL of the feed
		#   - update_interval: how often the feed should be updated
		#   - shorten_urls: whether we should shorten URLs
		#   - name: the name of the feed that should be displayed in a chat
		#   - channels: a list of channels we should tell about this feed.
		def get_feed(feed)
			feed = config['feeds'].find{ |f|
				f.is_a?(String) ? (f == feed) : (f['url'] == feed)
			}
			return if not feed
			
			if feed.is_a?(String)
				feed = {'url' => feed}
			else
				feed = feed.clone
			end

			if feed['channels']
				feed['channels'] = feed['channels'].map{|_|Channel.new(_)}
			else
				feed['channels'] = bot.channels
			end

			feed['update_interval'] ||= config['update_interval']
			feed['shorten_urls'] ||= !config['bitly'].nil?

			feed
		end

		# Fetches a feed and tell all our channels about it. feed is a result from
		# get_feed(), last_fetched is the time when the feed was last fetched. Only
		# articles than last_fetched will be displayed.
		def fetch_feed(feed, last_fetched)
			bot.debug("Querying #{feed['url']}...")

			begin
				rss = ::RSS::Parser.parse(open(feed['url']).read(), false)
			rescue SocketError
				bot.debug("We encountered an error fetching #{feed['url']}. Aborting.")
				return
			rescue ::RSS::NotWellFormedError
				bot.debug("We encountered an error parsing #{feed['url']}. Aborting.")
				return
			end
		
			feed_title = (
				feed['name'] or
				(rss.channel and rss.channel.title) or
				rss.title
			)

			unless feed_title
				bot.debug("#{feed['url']} has no title. Ignoring.")
				return
			end

			rss.items.each do |article|
				if not article.date
					bot.debug("Article #{article.title} has no date. Ignoring.")
					next

				elsif not article.title
					bot.debug("Article in #{feed['url']} has no title. Ignoring.")
					next

				elsif article.date > last_fetched
					bot.debug("Article #{article.title} in #{feed['url']} is new!")

					begin
						short = shorten(article.link)
						bot.debug("Shortened URL #{article.link} to #{short}.")
					rescue
						bot.debug("Error shortening URL #{article.link}. Continuing.")
						short = article.link
					end

					feed['channels'].each do |c|
						c.safe_msg("#{article.title} - #{short} (via #{feed_title})")
					end
				end
			end

			bot.debug("Updated #{feed['url']}.")
		end
	end
end
