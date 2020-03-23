class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    require 'open-uri'
    @livestream=Livestream.where({:started=>true,:ended=>false}).each do |livestream|
      seconds_ago=DateTime.now.to_i-livestream.last_ping.to_i
      @livestream.update_attribute(:ended,true) if(seconds_ago>60)
    end
   
    puts "[PingLivestreamJob] stop"

  end
end
