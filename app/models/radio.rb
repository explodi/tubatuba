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
end
