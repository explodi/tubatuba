task :play_radio => :environment do
  Radio.fill_queue
  MPD_CLIENT.sendcommand('play') if MPD_CLIENT.paused?
end
task :get_cameras => :environment do
  GetCamerasJob.perform_now
end
