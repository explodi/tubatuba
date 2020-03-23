task :play_radio => :environment do
  Radio.fill_queue
  MPD_CLIENT.sendcommand('play') if MPD_CLIENT.paused?
end
task :get_cameras => :environment do
  GetCamerasJob.perform_now
end
task :import_old_cameras => :environment do
  old_cameras=JSON.parse(open(Rails.root.join("public","import_cameras.json")).read)
  old_cameras.each do |url|
      uri=URI(url)
      if SecurityCamera.where({:ip_str=>uri.host}).count==0

        @cam=SecurityCamera.new({:ip_str=>uri.host,:port=>uri.port,:uuid=>SecureRandom.uuid})
        @cam.save
        CameraImageJob.perform_later @cam
        puts @cam.inspect
      end
  end
end
task :refresh_all_cameras => :environment do
  SecurityCamera.all.each do |cam|
    CameraImageJob.perform_later cam

  end
end