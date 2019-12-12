class Song < ApplicationRecord
    def find_info
        puts self.md5
        require "id3tag"
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
                ffprobe_command="ffprobe -i #{self.file_path}"
                system(ffprobe_command)
            rescue => e
                puts "[ffprobe] #{e.inspect}"
            end
        end
    end
    def file_path
        return Rails.root.join('radio',"#{md5}.mp3")
    end
    def artist_name
        if self.artist_id
            return Artist.find(artist_id).name
        else
            return nil
        end
    end
end
