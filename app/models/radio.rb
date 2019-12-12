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
    def self.fill_queue
        MPD_CLIENT.connect if !MPD_CLIENT.connected?
        if MPD_CLIENT.queue.length<20
            Song.order("RANDOM ()").limit(20).each do |song|
                puts song.inspect
                puts song.md5.inspect
                MPD_CLIENT.add("#{song.md5}.mp3")
            end
        end
    end
end
