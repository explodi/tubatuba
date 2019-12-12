task :play_radio => :environment do
  Radio.fill_queue
  MPD_CLIENT.sendcommand('play') if MPD_CLIENT.paused?
end
