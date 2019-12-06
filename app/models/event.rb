class Event < ApplicationRecord
    validates :url_id, uniqueness: true

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
    def screenshot
        begin
            uuid=SecureRandom.uuid
            command="google-chrome --headless --enable-logging --virtual-time-budget=10000 --disable-gpu --no-sandbox --screenshot=\"#{Rails.root.join('public')}/#{uuid}.png\" \"https://tubatuba.net/event/#{self.url_id}\""
            puts command
            system(command)
            self.update_attribute(:screenshot_uuid,uuid)
            puts self.screenshot_url
        rescue => e
            puts e.message
        end
    end
    def screenshot_url
        if self.screenshot_uuid
            return "https://tubatuba.net/#{self.screenshot_uuid}.png"
        else
            return nil
        end
    end
end
