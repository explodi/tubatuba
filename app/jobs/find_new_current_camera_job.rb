class FindNewCurrentCameraJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "[FindNewCurrentCameraJob]"
    offset = rand(SecurityCamera.count)
    @random_camera=SecurityCamera.offset(offset).first
    if @random_camera.save_image
      puts "[found camera] #{@random_camera.id}"
      REDIS.set("current:camera",@random_camera.id) 
      REDIS.set("camera:timer","1")
      REDIS.expire("camera:timer",60)
      
    end
  end
end
