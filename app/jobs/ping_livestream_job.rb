class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    require 'open-uri'
    @livestream=Livestream.where({:started=>true,:ended=>false}).first
    if @livestream
      begin 
        video_playlist=open("https://video.tubatuba.net/hack-the-planet/index.m3u8").read
        puts video_playlist.inspect
        @livestream.update_attribute({:last_ping=>DateTime.now})
        puts @livestream.inspect
      rescue => e
        puts "#{e.message}"
      end
    end
    puts "[PingLivestreamJob] stop"

  end
end
