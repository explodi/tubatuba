class Song < ApplicationRecord
    def find_info
        puts self.md5
        require "id3tag"
        mp3_file = File.open(self.file_path, "rb")
        tag = ID3Tag.read(mp3_file)
        self.update_attribute(:title,tag.title);
    end
    def file_path
        return Rails.root.join('radio',"#{md5}.mp3")
    end
end
