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
			searches = db.execute("select * from searches;")
			searches.map do |search|
				Search.new(term: search[1], time: search[2], url: search[3], db: db)
			end
		end

		def to_database(db)
			db.execute("delete from searches;")
			kids.each do |search|
				db.execute("insert into searches (term, time, url) values ('#{search.term}', '#{search.time}', '#{search.url}');")
			end
		end
	end

	attr_reader :url, :time, :term, :db
	def initialize(args)
		@url = args[:url]
		@time = (args[:time] ? Time.parse(args[:time]) : (Time.now - 999999))
		@term = args[:term]
		@db = args[:db]
	end

	def fetch_results
		same_terms = (self.class.kids - [self]).select { |s| s.time && s.term == @term }
		most_recent = same_terms.map(&:time).max
		if most_recent.nil? || (Time.now - most_recent > 600)
			pc = PostContainer.from_url(@url)

			begin
				pc.each {|p| p.save_to_db(@term, db)}
				true
			rescue
				false
			end

			@time = Time.now
			pc
		else
			PostContainer.from_db(@term, db)
		end
	end
end
