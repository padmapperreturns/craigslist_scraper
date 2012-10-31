require 'simplecov'
SimpleCov.start
require './lib/post_container.rb'
require 'DBFaker.rb'
require 'sqlite3'

describe PostContainer do

  context ".from_url" do
    before(:each) do
      @pc = PostContainer.from_url("./spec/post_container_test_page.html")
    end

    it "should create a post container from url" do
      @pc.should_not be_nil
    end

    it "should contain posts" do
      @pc[0].should be_an_instance_of Post
    end
  end

  context ".from_db" do
    include DBFaker

    before(:all) do
      create_db_faker
      insert_one_row_db_faker
    end

    before(:each) do
      @pc = PostContainer.from_db("term", @db )
    end

    it "creates a post container" do
      @pc.should_not be_nil
    end

    it "should contain posts" do
      @pc[0].should be_an_instance_of Post
    end

    it "should contain a post that matches the term" do
      @pc[0].term.should == "term"
    end

    after(:all) do
      drop_table_db_faker
    end
  end
end