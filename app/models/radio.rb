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
        queue=MPD_CLIENT.queue
        queue_md5=[]
        queue.each do |queue_song|
            md5=queue_song.file.split(".")[0]
            queue_md5.push(md5)
        end
        if queue.length<20
            Song.order("RANDOM ()").limit(20).each do |song|
                unless queue_md5.include? song.md5
                    begin
                        puts "[add] #{song.md5}"
                        puts MPD_CLIENT.add("#{song.md5}.mp3").inspect
                    rescue => e
                        puts "[add error] #{e.message}"
                    end
                end
            end
        end
    end
end
