class CreateVideosJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @event=args[0]
    VideoFormat.all.each do |f|
      REDIS.set("video_queue:#{@event.id}:#{f.id}","1")
      @event.record_video(f)
    end
  end
end
