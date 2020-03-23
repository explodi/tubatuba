class GetCamerasJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something 
    require 'open-uri'
    url="https://api.shodan.io/shodan/host/search?key=IOtrenXXJVQEkyy7adH6ztXzxn5gQ4Cv&query=#{URI::escape('webcamxp')}"
    matches=JSON.parse(open(url).read)["matches"]
    matches.each do |match|
      if SecurityCamera.where({:ip_str=>match["ip_str"]}).count==0

      
        @camera=SecurityCamera.new({
          :ip_str=>match["ip_str"],
          :port=>match["port"],
          :uuid=>SecureRandom.uuid
        })
        @camera.save
        puts "[new camera] #{@camera.ip_str}"
        CameraImageJob.perform_later @camera
      end
    end
    puts "[total cameras] #{SecurityCamera.all.count}"
  end
end
