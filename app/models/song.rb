class Song < ApplicationRecord
    def find_info
        puts self.md5
        require "id3tag"
        if File.file?(self.file_path)
            mp3_file = File.open(self.file_path, "rb")
            tag = ID3Tag.read(mp3_file)
            if tag
                self.update_attribute(:title,tag.title) if tag.title
                if tag.artist
                    artist=Artist.find_or_create_by({:name=>tag.artist}) 
                    self.update_attribute(:artist_id,artist.id);
                end
            end
        end
    end
    def file_path
        return Rails.root.join('radio',"#{md5}.mp3")
    end
end
