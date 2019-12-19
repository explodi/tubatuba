class CreateVideosJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "[create videos job] start"
    @event=args[0]
    VideoFormat.all.each do |f|
      REDIS.set("video_queue:#{@event.id}:#{f.id}","1")
      @event.record_video(f)
    end

    puts "[create videos job] end"
  end
end
