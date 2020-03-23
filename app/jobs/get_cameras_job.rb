class GetCamerasJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something 
    require 'open-uri'
    url="https://api.shodan.io/shodan/host/search?key=IOtrenXXJVQEkyy7adH6ztXzxn5gQ4Cv&query=#{URI::escape('webcamxp')}"
    puts url
    matches=JSON.parse(open(url).read)["matches"]
    puts matches.inspect
    matches.each do |match|
      @camera=SecurityCamera.find_or_create_by({
        :ip_str=>match["ip_str"],
        :uuid=>SecureRandom.uuid,
        :port=>match["port"]})
      end
    puts "[total cameras] #{SecurityCamera.all.count}"
  end
end
