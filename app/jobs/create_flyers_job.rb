class CreateFlyersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @event=args[0]
    Event.flyer_formats.each do |f|
      @event.screenshot(f[0],f[1])
    end
  end
end
