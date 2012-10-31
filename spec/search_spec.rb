require 'search'
require 'sqlite3'

describe "Search" do

	it "saves all instantiations"	do
		s1 = Search.new(url: "http://")
		Search.kids.length.should eql 1
		Search.kids.first.should be_a Search
		s2 = Search.new(url: "http://")
		Search.kids.length.should eql 2
		Search.kids.first.should be_a Search
	end

	describe "database stuff" do
		before :each do
			@db = SQLite3::Database.new "spec/testing.db"
			make_schema = <<EOF
CREATE TABLE IF NOT EXISTS searches (
id INTEGER PRIMARY KEY AUTOINCREMENT,
link VARCHAR NOT NULL,
term VARCHAR NOT NULL,
created_at VARCHAR NOT NULL,
updated_at VARCHAR NOT NULL
);
EOF
			@db.execute(make_schema)
			@db.execute("insert into searches (link, term, created_at, updated_at) values ('joe', 'bob', 'something', 'else');")
			#system("sqlite3 spec/testing.db < db/schema.sql")
		end

		it "loads previous searches from the database" do

			db_searches = @db.execute("select * from searches")
			db_searches.should be_an Array
			db_searches.first.should be_an Array

			searches = Search.from_database(@db)
			searches.should be_an Array
			searches.first.should be_a Search
		end
	end

	describe "caching decisions" do
		before :each do
			class PostContainer
			end
			PostContainer.stub(:from_url).and_return(:from_url_called)
			PostContainer.stub(:from_db).and_return(:from_db_called)

		end

		it "should load from the web if no previous search with that term" do
			first_search = Search.new(term: "san francisco")
			first_search.fetch_results.should eql(:from_url_called)
		end

		it "should load from the web if no fresh searches with that term" do
			Search.new(term: "san francisco", time: Time.now - 999999)
			s = Search.new(term: "san francisco")
			s.fetch_results.should eql(:from_url_called)
		end

		it "should load from the database if there is a fresh search in there" do
			Search.new(term: "san francisco", time: Time.now)
			s = Search.new(term: "san francisco")
			s.fetch_results.should eql(:from_db_called)
		end

	end
end