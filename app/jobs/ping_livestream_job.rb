class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    require 'open-uri'
    @livestream=Livestream.where({:started=>true,:ended=>false}).first
    if @livestream
      begin 
        video_playlist=open("https://hls.tubatuba.net/hack-the-planet/index.m3u8").read
        puts video_playlist.inspect
        @livestream.last_ping=DateTime.now
        @livestream.save
        puts @livestream.inspect
      rescue => e
        puts "#{e.message}"
      end
      seconds_ago=DateTime.now.to_i-@livestream.last_ping.to_i
      puts seconds_ago.inspect
      if(seconds_ago>60)
        @livestream.update_attribute(:ended,true) 
        REDIS.del("live_buffering")
        REDIS.del("live_online")
      end
    end
    puts "[PingLivestreamJob] stop"

  end
end
