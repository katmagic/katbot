#!/usr/bin/env ruby

class QuotesDB
	# If quotes_file is improperly formatted, our behavior is undefined (and
	# erratic).
	def initialize(quotes_file="quotes.txt")
		@quotes_file = quotes_file

		load_quotes()
	end

	# For each quote in quotes_file, call the provided block with the Array tags,
	# the String quote, and the String author. (An example quotes file can be
	# found in quotes.txt.)
	def each_quote_in_file(quotes_file)
		qf = open(quotes_file)

		while chunk = qf.gets("")
			chunk = chunk.strip().lines.to_a
			tags = chunk.delete_at(0).split()
			author = chunk.delete_at(-1).match(/^\s*~\s*(.*?)\s*$/)[1]
			quote = chunk.join(" ").gsub(/\s+/, " ").strip()

			yield(tags, quote, author)
		end

		qf.close()
	end

	# Get a random quote.
	def get_quote()
		@quotes.sample
	end

	# Get a quote with a given tag.
	def get_quote_by_tag(tag)
		@tags[tag].sample
	end

	# Get a quote by the given author.
	def get_quote_by_author(author)
		@authors[author].sample
	end

	private

	# Load the quotes from @quotes_file into @quotes, @tags, and @authors. This is
	# an incredibly inefficient way of doing things.
	def load_quotes()	
		@authors = Hash.new{|h, k| h[k] = []}
		@tags = Hash.new{|h, k| h[k] = []}
		@quotes = Array.new

		each_quote_in_file(@quotes_file) do  |tags, quote_, author|
			quote = "#{quote_}\n~ #{author}"
			@quotes << quote
			@authors[author] << quote
			tags.each do |tag|
				@tags[tag] << quote
			end
		end

		nil
	end
end
