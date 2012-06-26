#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'
require 'sqlite3'

start_word = "ecstatic"

db = SQLite3::Database.new("songs.db")

db.busy_handler() do |s, r|
    sleep 0.1
    true
end

File.readlines("/usr/share/dict/words").each do |word|
    if word.chomp.downcase <= start_word.downcase
        next
    end

    puts word.chomp.downcase

    begin
        data = JSON.parse(open("http://itunes.apple.com/search?term=#{word.chomp}&media=music&entity=musicTrack&limit=200").read)
    rescue OpenURI::HTTPError
        next
    end

    data["results"].each do |track|
        if db.execute("SELECT COUNT(*) FROM songs WHERE song_id = ?",
                      track["trackId"])[0][0] == 0
            db.execute("INSERT INTO songs VALUES (?, ?, ?, ?)",
                       track["trackId"],
                       track["trackName"],
                       track["primaryGenreName"],
                       track["trackTimeMillis"])
            p [track["trackId"],
               track["trackName"],
               track["primaryGenreName"],
               track["trackTimeMillis"]]
        end
    end
end
