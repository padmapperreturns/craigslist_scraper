require 'nokogiri'
require 'open-uri'

class Post
  attr_accessor :date_time, :posting_title, :listing_price, :location, :url, :term

  def self.from_db(post_id, db)
    attr_array = db.execute("SELECT * FROM posts WHERE id = #{post_id};")
    p = Post.new
    p.date_time = attr_array[0][1]
    p.posting_title = attr_array[0][2]
    p.listing_price = attr_array[0][3]
    p.location = attr_array[0][4]
    p.term = attr_array[0][6]
    p
  end

  def self.from_url(url)
    p = Post.new
    @doc = open_url(url)
    p.date_time = format_date_time
    p.posting_title = posting_title
    p.listing_price = listing_price
    p.location = location
    p.url = url
    p
  end

  def self.open_url(url)
    Nokogiri::HTML(open(url))
  end

  def self.format_date_time
    a = Time.parse @doc.xpath("//span[@class='postingdate']").first.content.gsub('Date: ', "")
    a.strftime("%Y-%m-%d %H:%M")
  end

  def self.posting_title
    @doc.xpath("//title").first.content
  end

  def self.listing_price
    @doc.xpath("//h2").first.content.match(/\$(\d+)/).to_a.last.to_i || 0
  end

  def self.location
    @doc.xpath("//h2").first.content.match(/\((.*)\)/).to_a.last || "earth"
  end

  def save_to_db(term, db)
    db.execute("INSERT INTO posts
    (date_time, posting_title, listing_price, location, url, term)
    VALUES ('#{date_time}',
    '#{posting_title}',
    '#{listing_price}',
    '#{location}',
    '#{url}',
    '#{term}');"
    )
  end
end