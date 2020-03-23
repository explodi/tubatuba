class SecurityCamera < ApplicationRecord
    validates_uniqueness_of :ip_str

    def image_url
        return "http://#{self.ip_str}:#{self.port}/cam_1.jpg"
    end
    def last_camera_image_url
        return "/cameras/#{self.uuid}/#{last_camera_image}"
    end
    def last_camera_image
        last_timestamp=0
        first_timestamp=DateTime.now.to_i
        puts self.camera_image_dir
        image_files= Dir.entries(self.camera_image_dir)
        image_files.each do |file|
            timestamp=file.split(".").first.to_i
            if timestamp!=0 && timestamp>last_timestamp
                last_timestamp=timestamp
            end
            if timestamp>0 && timestamp<first_timestamp
                first_timestamp=timestamp
            end
        end
        puts "[total files] #{image_files.count}"
        if image_files.count>1000
            old_file_path="#{self.camera_image_dir}/#{first_timestamp}.jpg"
            puts "[delete old image] #{old_file_path}"
            FileUtils.rm(old_file_path)
        end
        if last_timestamp&&last_timestamp>0
            return last_timestamp.to_s+".jpg"
        else
            return nil
        end
    end
    def camera_image_dir
        dir=Rails.root.join("public","cameras",self.uuid)

        if(File.directory?(dir)==false)
            FileUtils.mkdir_p(dir)
        end
        return dir
    end
    def save_image
        tmp_dir=Rails.root.join("tmp")
        if(File.directory?(tmp_dir)==false)
            FileUtils.mkdir_p(tmp_dir)
        end
        tmp_path="#{tmp_dir}/#{SecureRandom.hex}.jpg"
        puts tmp_path
        begin
            open(self.image_url) {|f|
            File.open(tmp_path,"wb") do |file|
                file.puts f.read
            end
            }

            final_path="#{self.camera_image_dir}/#{DateTime.now.to_i.to_s}.jpg"
            convert_command="convert #{tmp_path} -resize 1920x1080^ -gravity center -quality 75 #{final_path}"
            return false if !system(convert_command)
            self.update_attribute(:last_seen,DateTime.now)
            REDIS.del("screenshot:timer")

            return true
        rescue => e            
            puts e.message
            return false
        end
    end
end
