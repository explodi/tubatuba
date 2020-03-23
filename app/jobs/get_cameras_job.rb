class GetCamerasJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something 
    require 'open-uri'
    url="https://api.shodan.io/shodan/host/search?key=IOtrenXXJVQEkyy7adH6ztXzxn5gQ4Cv&query=#{URI::escape('webcamxp')}"
    matches=JSON.parse(open(url).read)["matches"]
    matches.each do |match|
      @camera=SecurityCamera.find_or_create_by({
        :ip_str=>match["ip_str"],
        :port=>match["port"]
      })
      if !@camera.uuid
        @camera.uuid=SecureRandom.uuid 
        @camera.save
      end
    end
    puts "[total cameras] #{SecurityCamera.all.count}"
  end
end
