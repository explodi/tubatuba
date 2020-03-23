class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    require 'open-uri'
    @livestream=Livestream.where({:started=>true,:ended=>false}).each do |livestream|
      seconds_ago=DateTime.now.to_i-livestream.last_ping.to_i
      if(seconds_ago>60)
        @livestream.update_attribute(:ended,true) 
        REDIS.del("live_buffering")
        REDIS.del("live_online")
      end
    end
   
    puts "[PingLivestreamJob] stop"

  end
end
