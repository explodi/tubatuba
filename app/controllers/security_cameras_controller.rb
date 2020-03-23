class SecurityCamerasController < ApplicationController
    def feed
        require 'open-uri'
        current_camera_key="current:camera"
        if REDIS.exists(current_camera_key)
            @camera=SecurityCamera.find(REDIS.get(current_camera_key))
        else
            offset = rand(SecurityCamera.count)
            @camera=SecurityCamera.offset(offset).first
        end
        tmp_dir=Rails.root.join("tmp")
        if(File.directory?(tmp_dir)==false)
            File.mkdir_p(tmp_dir)
        end
        tmp_path="#{tmp_dir}/#{SecureRandom.hex}.jpg"
        puts tmp_path
        begin
            open(@camera.image_url) {|f|
            File.open(tmp_path,"wb") do |file|
                file.puts f.read
            end
            }
            camera_image_dir=Rails.root.join("public","cameras",DateTime.now.year.to_s,DateTime.now.month.to_s,DateTime.now.day.to_s,@camera.uuid)

            if(File.directory?(camera_image_dir)==false)
                File.mkdir_p(camera_image_dir)
            end
            final_path="#{camera_image_dir}/#{DateTime.now.to_i.to_s}.jpg"
            convert_command="convert #{tmp_path} -resize=1920x1080 -quality 75 #{final_path}"
            system convert_command
        rescue => e
            puts e.message
        end

        render :json=>@camera.image_url
    end
end
