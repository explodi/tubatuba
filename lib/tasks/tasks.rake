task :play_radio => :environment do
  MPD_CLIENT.sendcommand('play')
end
