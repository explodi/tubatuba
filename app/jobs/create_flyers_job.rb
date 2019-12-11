class CreateFlyersJob < ApplicationJob
  queue_as :default

  def perform(*args)

    @event=args[0]
    VideoFormat.all.each do |f|
      @event.screenshot(f)
    end
  end
end
