require 'ruby-mpd'
begin
    mpd_host= Rails.env.development? ? 'elemurro' : 'mpd'
    MPD_CLIENT = MPD.new mpd_host, 6600
    MPD_CLIENT.connect
    MPD_CLIENT.play if MPD_CLIENT.stopped?
    MPD_CLIENT.send_command('repeat',1)
rescue => e
    puts e.message
end