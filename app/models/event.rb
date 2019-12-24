class Event < ApplicationRecord
    validates :url_id, uniqueness: true
    def self.next_event
        events=Event.next_events
        return events.first if events.length>0
        return nil
    end
    def self.next_events
        return Event.where("'end' > ?",DateTime.now).where(:deleted=>false)
    end
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
    def screenshot(video_format)
        if video_format.width && video_format.height && video_format.name && self.url_id
            puts "[screenshot] #{video_format.width}x#{video_format.height}"
            uuid=SecureRandom.uuid

            dirname = Rails.root.join("public","image","#{self.id}")
            unless File.directory?(dirname)
                FileUtils.mkdir_p(dirname)
            end
            command="google-chrome --headless --enable-logging --virtual-time-budget=10000 --window-size=#{video_format.width.to_s}x#{video_format.height.to_s} --disable-gpu --virtual-time-budget=10000 --no-sandbox --screenshot=\"#{Rails.root.join('public','image',self.id.to_s,"#{video_format.name}.png")}\" \"https://tubatuba.net/evento/#{self.url_id}/#{video_format.id.to_s}\""
            puts command
            system(command)
        end
    end
    def screenshot_url(video_format)
        return "https://tubatuba.net/image/#{self.id}/#{video_format.name}.png"
    end
    def audio_path
        return Rails.root.join("public","audio","#{self.id}.mp3")
    end
    def has_audio
        return File.exist?(self.audio_path)
    end
    def audio_link
        return "/audio/#{self.id}.mp3"
    end
    def video_exists(format_name)
        return File.exist?(self.video_path(format_name))
    end
    def video_ad_exists
        return File.exist?(self.ad_video_path)
    end
    
    def video_link(format_name)
        return "/video/#{self.id}/#{format_name}.mp4"
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
            ffmpeg_command="ffmpeg -i #{capture_path} -i #{audio_path} -y -f mp4 -vcodec libx264 -preset fast -profile:v main -acodec aac -shortest -hide_banner -loglevel panic #{self.ad_video_path}"
        end
        puts "[ffmpeg] #{ffmpeg_command}"
        system(ffmpeg_command)
        return true

    end
    def record_video(f)
        require 'fileutils'
        puts "[record video] format: #{f.name} start"
        start_time=DateTime.now

        filename="#{f.name}.webm"
        command="node #{Rails.root.join("export.js")} https://tubatuba.net/evento/#{self.url_id}/#{f.id} #{filename} #{f.width} #{f.height}"
        puts command
        system(command)

        dirname = Rails.root.join("public","video","#{self.id}")
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dirname)
        end
        capture_path="/root/Downloads/#{filename}"
        ffmpeg_command="ffmpeg -i #{capture_path} -y #{self.video_path(f.name)}"
        if self.has_audio
            ffmpeg_command="ffmpeg -i #{capture_path} -sseof -15 -i #{audio_path} -ss 00:00:00 -to 00:00:15 -y -f mp4 -vcodec libx264 -preset veryslow -crf 23 -maxrate 8M -bufsize 12M -profile:v main -acodec aac -shortest -hide_banner -loglevel panic #{self.video_path(f.name)}"
            # ffmpeg_command="ffmpeg -i #{capture_path} -sseof -15 -i #{audio_path} -ss 00:00:00 -to 00:00:15 -y -f mp4 -vcodec libx264 -preset veryslow -crf 23 -maxrate 8M -bufsize 12M -profile:v main -acodec aac -shortest -vf scale=#{f.width}:#{f.height},setsar=1 -hide_banner -loglevel panic #{self.video_path(f.name)}"
        end
        puts "[ffmpeg] #{ffmpeg_command}"
        system(ffmpeg_command)
        REDIS.del("video_queue:#{self.id}:#{f.id}")
        end_time=DateTime.now

        puts "[record video] format: #{f.name} took: #{end_time.to_i-start_time.to_i}"

        return true

    end
end
