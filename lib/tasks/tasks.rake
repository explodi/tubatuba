task :play_radio => :environment do
  MPD_CLIENT.sendcommand('play') if MPD_CLIENT.paused?
end
