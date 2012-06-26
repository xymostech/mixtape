#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'
require 'sqlite3'

db = SQLite3::Database.new("songs.db")

start = db.execute("SELECT MAX(song_id) FROM songs")[0][0]
endnum = 540000000
step = 100

threads = []

0.upto(9) do |offset|
    threads << Thread.new(offset * 10) do |o|
        (start..endnum).step(step) do |n|
            begin
                data = JSON.parse(open("http://itunes.apple.com/lookup?id=#{n+o}").read)
            rescue OpenURI::HTTPError
                next
            end

            if data["resultCount"] > 0
                if data["results"][0]["wrapperType"] == "track"
                    track = data["results"][0]
                    if db.execute("SELECT COUNT(*) FROM songs WHERE song_id = ?",
                                  track["trackId"])[0][0] == 0
                        db.execute("INSERT INTO songs VALUES (?, ?, ?)",
                                   track["trackName"],
                                   track["trackId"],
                                   track["trackTimeMillis"])
                        p [track["trackName"], track["trackId"], track["trackTimeMillis"]]
                    end
                end
            end
        end
    end
end

threads.each do |thread|
    thread.join
end
