class Search

	class << self
		@@kids ||= []

		def kids
			@@kids
		end

		def new(*args)
			new_search = super(*args)
			@@kids << new_search
			new_search
		end

		def from_database(db)
			searches = db.execute("select * from searches")
			searches.map do |search|
				Search.new(term: search[0], time: search[1], url: search[2])
			end
		end
	end

	attr_reader :url, :time, :term, :db
	def initialize(args)
		@url = args[:url]
		@time = args[:time]
		@term = args[:term]
		@db = args[:db]
	end

	def fetch_results
		same_terms = (self.class.kids - [self]).select { |s| s.time && s.term == @term }
		most_recent = same_terms.map(&:time).max
		if most_recent.nil? || (Time.now - most_recent > 600)
			PostContainer.from_url(@url)
		else
			PostContainer.from_db(@term, @db)
		end
	end
end
