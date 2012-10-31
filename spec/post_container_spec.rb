require 'simplecov'
SimpleCov.start
require './lib/post_container.rb'

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

  end
end