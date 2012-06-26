#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'
require 'sqlite3'

start_word = ARGV[0]
end_word = ARGV[1]

db = SQLite3::Database.new("songs.db")

db.busy_handler do |s, r|
    sleep 0.1
    true
end

db.execute_batch <<-SQL
  DROP TABLE IF EXISTS songs;
  DROP TABLE IF EXISTS words;
  CREATE TABLE IF NOT EXISTS songs (
    song_id INT,
    song_name TEXT,
    genre TEXT,
    length INT,
    artist_id INT,
    artist_name TEXT,
    collection_id INT,
    collection_name TEXT,
    preview_url TEXT,
    track_price INT,
    year INT,
    disc_count INT,
    disc_number INT,
    track_count INT,
    track_number INT,
    country TEXT
  );
  CREATE TABLE IF NOT EXISTS words (
    word TEXT
  );
  CREATE UNIQUE INDEX index_song_id ON songs ( song_id );
SQL

File.readlines("words").each do |word|
    puts word.chomp.downcase

    begin
        data = JSON.parse(open("http://itunes.apple.com/search?term=#{word.chomp}&media=music&entity=musicTrack&limit=200").read)
    rescue OpenURI::HTTPError, Timeout::Error
        redo
    end

    data["results"].each do |track|
        if db.execute("SELECT COUNT(*) FROM songs WHERE song_id = ?",
                      track["trackId"])[0][0] == 0
            db.execute(
                "INSERT INTO songs VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                track["trackId"],
                track["trackName"],
                track["primaryGenreName"],
                track["trackTimeMillis"],
                track["artistId"],
                track["artistName"],
                track["collectionId"],
                track["collectionName"],
                track["previewUrl"],
                (track["trackPrice"] * 100).round,
                track["releaseDate"][0..4].to_i,
                track["discCount"],
                track["discNumber"],
                track["trackCount"],
                track["trackNumber"],
                track["country"]
            )
        end
    end

    db.execute("INSERT INTO words VALUES (?)", word.chomp)
end
