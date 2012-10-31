require 'search'
require 'DBFaker'
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
		include DBFaker
		before :each do
      create_db_faker
      @db.execute("insert into searches (term, time, url) values ('soma', '1 Jan 2000', 'http://example.com');")
		end

		after :each do
	    drop_table_db_faker
		end

		it "loads previous searches from the database" do

			db_searches = @db.execute("select * from searches")
			p db_searches
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