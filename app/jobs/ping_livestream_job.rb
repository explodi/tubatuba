class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    require 'open-uri'
    @livestream=Livestream.where({:started=>true,:ended=>false}).each do |livestream|
      puts @livestream.inspect
      puts DateTime.now.to_i-@livestream.last_ping.to_i
    end
   
    puts "[PingLivestreamJob] stop"

  end
end
