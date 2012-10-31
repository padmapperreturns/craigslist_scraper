require 'nokogiri'
require 'open-uri'
require './lib/post.rb'

class PostContainer < Array

  def self.from_db(term, db)

  end

  def self.from_url(url)
    pc = PostContainer.new
    @doc = open_url(url)
    scraped_links.each do |link|
      pc << Post.from_url(link)
    end

    pc
  end

  def self.open_url(url)
    Nokogiri::HTML(open(url))
  end

  # an array of links to individual posts, iterate over them creating new posts, shoveling into self

  def self.scraped_links
    posts = @doc.css('span.itemsep+a')
    links = []
    posts.each_with_index do |post, index|
      links << posts[index]['href']
    end

    links
  end

end