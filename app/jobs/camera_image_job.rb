class CameraImageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    @camera=args[0]
    @camera.save_image
  end
end
