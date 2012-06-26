#!/usr/bin/env ruby

require 'rubygems'
require 'sqlite3'

db = SQLite3::Database.new("songs.db")

db.execute <<-SQL
  DROP TABLE IF EXISTS songs
SQL

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
    song_id INT,
    name varchar(40),
    genre varchar(40),
    length INT
  );
SQL

db.execute <<-SQL
  CREATE UNIQUE INDEX index_song_id ON songs ( song_id )
SQL
