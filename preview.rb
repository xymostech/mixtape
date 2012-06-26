#!/usr/bin/env ruby
#
require 'rubygems'
require 'json'
require 'open-uri'
require 'sqlite3'

`rm tape1/*`

File.readlines(ARGV[0]).each do |ids|
    data = JSON.parse(open("http://itunes.apple.com/lookup?id=#{ids}").read)

    if data["resultCount"] > 0
        if data["results"][0]["wrapperType"] == "track"
            track = data["results"][0]
            #puts track["previewUrl"]
            puts "#{track["trackName"]}, #{track["artistName"]}, #{track["collectionName"]} [#{track["releaseDate"][0..3]}]"
            puts "#{track["trackPrice"]}, #{track["trackTimeMillis"]/1000}"
            #puts track["collectionViewUrl"]
            `cd tape1; curl -s "#{track["previewUrl"]}" -O`
            puts
        end
    end
end

`mv #{ARGV[0]} #{Time.new.to_i.to_s + "-" + ARGV[0]}`

`open -a Vox tape1/*`
