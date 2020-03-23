class PingLivestreamJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "[PingLivestreamJob] start"
    puts "[PingLivestreamJob] stop"

  end
end
