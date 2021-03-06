class SecurityCamera < ApplicationRecord
    validates_uniqueness_of :ip_str

    def image_url
        return "http://#{self.ip_str}:#{self.port}/cam_1.jpg"
    end
    def last_camera_image_url
        return "/cameras/#{self.uuid}/#{last_camera_image}"
    end
    def image_urls
        urls=[]
        self.image_timestamps[0..100].each do |timestamp|
            urls.push("/cameras/#{self.uuid}/#{timestamp}.jpg")
        end
        return urls
    end
    def image_timestamps
        last_timestamp=0
        image_files= Dir.entries(self.camera_image_dir)
        timestamps=[]
        image_files.each do |file|
            timestamp=file.split(".").first.to_i
            if timestamp>0
                timestamps.push(timestamp)
            end            
        end
        timestamps.sort
        while timestamps.count>500
            old_file_path="#{self.camera_image_dir}/#{timestamps.shift}.jpg"
            puts "[delete old image] #{old_file_path}"
            FileUtils.rm(old_file_path)
        end
        timestamps.sort
        return timestamps
    end
    def last_camera_image
        last_timestamp=0
        first_timestamp=DateTime.now.to_i
        # puts self.camera_image_dir
        image_files= Dir.entries(self.camera_image_dir)
        image_files.each do |file|
            puts file.inspect
            timestamp=file.split(".").first.to_i
            if timestamp!=0 && timestamp>last_timestamp
                last_timestamp=timestamp
            end
            if timestamp>0 && timestamp<first_timestamp
                first_timestamp=timestamp
            end
        end
        # puts "[total files] #{image_files.count}"
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
        puts "[save image] #{self.ip_str}"
        tmp_dir=Rails.root.join("tmp")
        if(File.directory?(tmp_dir)==false)
            FileUtils.mkdir_p(tmp_dir)
        end
        tmp_path="#{tmp_dir}/#{SecureRandom.hex}.jpg"
        # puts tmp_path
        begin
            puts "[open] #{self.image_url}"
            # open(self.image_url) {|f|
            # File.open(tmp_path,"wb") do |file|
            #     file.puts f.read
            # end
            # }
            final_path="#{self.camera_image_dir}/#{DateTime.now.to_i.to_s}.jpg"

            # wget_command="wget #{self.image_url} --tries=1 --timeout=20 -O #{final_path}"
            Down.download(self.image_url,destination:tmp_path)
            # puts wget_command
            if File.file?(tmp_path)

                convert_command="convert #{tmp_path} -strip -interlace Plane -gaussian-blur 0.05 -resize 1080x1080^ -gravity center -extent 1080x1080 -quality 75 #{final_path}"
                puts "[convert] #{convert_command}"
                if system(convert_command)&&File.file?(final_path)
                    puts "[convert] ok"
                    self.update_attribute(:last_seen,DateTime.now)
                    # FileUtils.rm(tmp_path)
                    REDIS.del("screenshot:timer")
                    self.update_attribute(:error_count,0)  
                    return true
                else
                    puts "[convert] fail"
                    return false
                end
            
            else
                puts "[wget] fails"
                self.update_attribute(:error_count,self.error_count+1)  
                puts "[convert] command failed"
                return false 
            end
        rescue => e          
            self.update_attribute(:error_count,self.error_count+1)  
            puts e.message
            return false
        end
    end
end
