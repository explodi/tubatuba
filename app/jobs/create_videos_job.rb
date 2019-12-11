class CreateVideosJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @event=args[0]
    VideoFormat.all.each do |f|
      @event.record_video(f)
    end
    @event.record_ad
  end
end
