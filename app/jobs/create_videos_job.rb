class CreateVideosJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @event=args[0]
    @event.record_video(600,600)
    @event.record_video(1920,1080)
    
  end
end
