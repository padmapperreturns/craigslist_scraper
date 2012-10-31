require 'simplecov'
SimpleCov.start
require 'sqlite3'
require './lib/post.rb'
require 'DBFaker.rb'

describe Post do

  context ".from_url" do
    before(:each) do
      @post = Post.from_url("./spec/standard.html")
    end

    it "creates a post from url" do
      @post.should_not be_nil
    end

    it "should be a valid post" do
      [:posting_title, :listing_price, :location, :url].each do |method|
        @post.should respond_to(method)
      end
    end

    it "should have a properly formatted date time attribute" do
      @post.date_time.should =~ /\d{4}-\d{2}-\d{2} \d{2}:\d{2}/
    end

    it "should have the correct posting title" do
      @post.posting_title.should =~ /Amazing/
    end

    it "should have the correct listing price" do
      @post.listing_price.should == 1594
    end


    it "should have the correct location" do
      @post.location.should =~ /san mateo/
    end
  end

  context ".from_db" do
    include DBFaker

    before(:all) do
      create_db_faker
      insert_one_row_db_faker
    end

    before(:each) do
      @post = Post.from_db(1, @db)
    end

    it "should load the post that matches the post_id" do
      @post.listing_price.should == 1594
    end

    after(:all) do
      drop_table_db_faker
    end
  end

  context "#save_to_db" do
    include DBFaker

    before(:all) do
      create_db_faker
      insert_one_row_db_faker
    end

    it "should save a post to the database" do
      @db.execute("SELECT * FROM posts;").should_not be_nil
    end

    it "should store the information correctly" do
      @db.execute("SELECT listing_price FROM posts WHERE id = 1;").flatten.pop.should == 1594
    end

    it "should set a price of 0 if the listing has no price" do
      post = Post.from_url("./spec/no_price.html")
      post.save_to_db(@db)
      @db.execute("SELECT listing_price FROM posts WHERE listing_price = 0;").should_not be_nil
    end

    after(:all) do
      drop_table_db_faker
    end
  end

end