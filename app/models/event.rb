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
    def video_exists(width,height)
        return File.exist?(self.video_path(width,height))
    end
    def video_link(width,height)
        return "/video/#{self.id}/#{width}_#{height}.webm"
    end
    def video_path(width,height)
        filename="#{width}_#{height}.webm"
        return "#{Rails.root.join("public","video","#{self.id}",filename)}"
    end
    def record_video(width,height)
        require 'fileutils'

        # url="http://tubaflyer:8383/record"
        # puts url
        # puts "[format_string] #{format_string}"
        # frames=3000 if frames>3000
        # response=RestClient.post url, {:frames=>frames,:format_string=>format_string,:width=>width,:height=>height,:url=>"https://tubatuba.net/evento/#{self.url_id}"}
        # puts response.body
        # if JSON.parse(response.body)["success"]
        #     uuid=JSON.parse(response.body)["uuid"]
        #     @videoflyer=VideoFlyer.find_or_create_by({:event_id=>self.id,:width=>width,:height=>height,:format_string=>format_string})
        #     @videoflyer.update_attribute(:uuid,uuid)
        #     return true
        # else
        #     return false
        # end
        filename="#{width}_#{height}.webm"
        command="node #{Rails.root.join("export.js")} https://tubatuba.net/evento/#{self.url_id} #{filename} #{width} #{height}"
        puts command
        system(command)

        dirname = Rails.root.join("public","video","#{self.id}")
        unless File.directory?(dirname)
            FileUtils.mkdir_p(dirname)
        end
        FileUtils.mv("/root/Downloads/#{filename}",self.video_path(width,height))
        return true

    end
end
