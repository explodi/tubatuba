class Event < ApplicationRecord
    validates :url_id, uniqueness: true
    def self.flyer_formats
        [[600,600],[1920,1080]]
    end
    def acts
        return EventAct.where({:event_id=>self.id})
    end
    def generate_url_id
        if !self.url_id
            url_id=SecureRandom.uuid.split("-")[0]
            url_id="#{url_id}#{rand(0..100)}" if Event.exists?({:url_id=>url_id})
            self.update_attribute(:url_id,url_id)  
        end
    end
    def screenshot(width,height)
        puts "[screenshot] #{width}x#{height}"
        begin
            uuid=SecureRandom.uuid
            command="google-chrome --headless --enable-logging --virtual-time-budget=10000 --window-size=#{width}x#{height} --disable-gpu --no-sandbox --screenshot=\"#{Rails.root.join('public')}/#{uuid}.png\" \"https://tubatuba.net/evento/#{self.url_id}\""
            puts command
            system(command)
            flyer=Flyer.find_or_create_by({width:width,height:height,event_id:self.id})
            flyer.update_attribute(:uuid,uuid)
            return flyer
        rescue => e
            puts e.message
        end
    end
    def screenshot_url
        flyer=Flyer.where({:event_id=>self.id}).order("id DESC").first
        if flyer
            return "https://tubatuba.net/#{flyer.uuid}.png"
        else
            return nil
        end
    end
    def audio_path
        return Rails.root.join("public","audio","#{self.id}.mp3")
    end
    def has_audio
        return File.exist?(self.audio_path)
    end
    def video_exists(format_name)
        return File.exist?(self.video_path(format_name))
    end
    def video_ad_exists
        return File.exist?(self.ad_video_path)
    end
    
    def video_link(format_name)
        return "/video/#{self.id}/#{width}_#{height}.mp4"
    end
    def ad_video_link
        return "/video/#{self.id}/ad.mp4"
    end
    def video_path(format_name)
        filename="#{format_name}.mp4"
        return "#{Rails.root.join("public","video","#{self.id}",filename)}"
    end
    def ad_video_path
        return "#{Rails.root.join("public","video","#{self.id}","ad.mp4")}"
    end
    def record_ad
        require 'fileutils'


        filename="ad.webm"
        command="node #{Rails.root.join("export.js")} https://tubatuba.net/events/#{self.id}/ad #{filename} 600 600"
        puts command
        system(command)

        dirname = Rails.root.join("public","video","#{self.id}")
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dirname)
        end
        capture_path="/root/Downloads/#{filename}"
        ffmpeg_command="ffmpeg -i #{capture_path} -y #{self.ad_video_path}"
        if self.has_audio
            ffmpeg_command="ffmpeg -i #{capture_path} -i #{audio_path} -y -f mp4 -vcodec libx264 -preset fast -profile:v main -acodec aac -shortest #{self.ad_video_path}"
        end
        puts "[ffmpeg] #{ffmpeg_command}"
        system(ffmpeg_command)
        return true

    end
    def record_video(f)
        require 'fileutils'
        puts "[record video] format: #{f.name}"
        filename="#{f.name}.webm"
        command="node #{Rails.root.join("export.js")} https://tubatuba.net/evento/#{self.url_id} #{filename} #{f.width} #{f.height}"
        puts command
        system(command)

        dirname = Rails.root.join("public","video","#{self.id}")
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dirname)
        end
        capture_path="/root/Downloads/#{filename}"
        ffmpeg_command="ffmpeg -i #{capture_path} -y #{self.video_path(f.name)}"
        if self.has_audio
            ffmpeg_command="ffmpeg -i #{capture_path} -i #{audio_path} -y -f mp4 -vcodec libx264 -preset fast -profile:v main -acodec aac -shortest #{self.video_path(f.name)}"
        end
        puts "[ffmpeg] #{ffmpeg_command}"
        system(ffmpeg_command)
        return true

    end
end
