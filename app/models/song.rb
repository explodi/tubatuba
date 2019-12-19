class Song < ApplicationRecord
    def find_info
        puts self.md5
        require "id3tag"
        self.update_attribute(:uuid,SecureRandom.uuid) if !self.uuid
        if File.file?(self.file_path)
            mp3_file = File.open(self.file_path, "rb")
            tag = ID3Tag.read(mp3_file)
            if tag
                puts tag.inspect
                self.update_attribute(:title,tag.title) if tag.title
                if tag.artist
                    artist=Artist.find_or_create_by({:name=>tag.artist}) 
                    self.update_attribute(:artist_id,artist.id);
                end
            end
            begin
                ffprobe_command=`ffprobe -v quiet -print_format json -show_format -show_streams -i #{self.file_path}`
                probe=JSON.parse(ffprobe_command)
                if probe["streams"][0]["duration"]
                    duration=probe["streams"][0]["duration"].to_f
                    self.update_attribute(:duration,duration)
                end
            rescue => e
                puts "[ffprobe] #{e.inspect}"
            end
        end
    end
    def file_path
        return Rails.root.join('radio',"#{md5}.mp3")
    end
    def file_exists
        return File.file?(self.file_path)
    end
    def artist_name
        if self.artist_id
            return Artist.find(artist_id).name
        else
            return nil
        end
    end
end
