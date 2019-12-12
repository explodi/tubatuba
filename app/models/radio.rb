class Radio

    def self.current_song
        MPD_CLIENT.connect if !MPD_CLIENT.connected?
        song=MPD_CLIENT.current_song
        if song
            md5=song.file.split(".")[0]
            return {:file=>song.file,:title=>song.title,:artist=>song.artist}
        else
            return nil
        end
    end
    def self.is_in_queue(song)
        MPD_CLIENT.queue.each do |mpd_song|
            md5=mpd_song.file.split(".")[0]
            return true if md5==song.md5
        end
        return false
    end
    def self.fill_queue
        MPD_CLIENT.connect if !MPD_CLIENT.connected?
        MPD_CLIENT.play if MPD_CLIENT.paused?
        MPD_CLIENT.random=false if MPD_CLIENT.random?
        MPD_CLIENT.send_command('delete',0) if MPD_CLIENT.current_song && MPD_CLIENT.current_song.pos>0
        queue=MPD_CLIENT.queue
        queue_md5=[]
        queue.each do |queue_song|
            md5=queue_song.file.split(".")[0]
            queue_md5.push(md5)
        end
        if queue.length<20
            Song.order("RANDOM ()").limit(20).each do |song|
                unless Radio.is_in_queue(song)
                    begin
                        puts "[add] #{song.md5}"
                        puts MPD_CLIENT.add("#{song.md5}.mp3").inspect
                    rescue => e
                        puts "[add error] #{e.message}"
                    end
                end
            end
        end
        MPD_CLIENT.queue.each do |q|
            puts q.title
        end
    end
end
