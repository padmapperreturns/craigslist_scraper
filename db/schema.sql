CREATE TABLE IF NOT EXISTS posts (
id INTEGER PRIMARY KEY AUTOINCREMENT,
date_time VARCHAR NOT NULL,
posting_title VARCHAR NOT NULL,
listing_price INTEGER NOT NULL,
location VARCHAR NOT NULL,
url VARCHAR NOT NULL
);