module DBFaker
  def create_db_faker
    @db = SQLite3::Database.new ("./db/test.db")
    system("sqlite3 ./db/test.db < ./db/schema.sql")
  end

  def insert_one_row_db_faker
    @post = Post.from_url("./spec/standard.html")
    @post.save_to_db("term", @db)
  end

  def drop_table_db_faker
    @db.execute("DROP TABLE posts;")
  end
end