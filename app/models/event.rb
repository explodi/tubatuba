class Event < ApplicationRecord
    def acts
        return EventAct.where({:event_id=>self.id})
    end
    def screenshot
        uuid=SecureRandom.uuid
        command="google-chrome --headless --enable-logging --virtual-time-budget=10000 --disable-gpu --no-sandbox --screenshot=\"#{Rails.root.join('public')}/#{uuid}.png\" \"https://tubatuba.net/\""
        puts command
        system(command)
        self.update_attribute(:screenshot_uuid,uuid)
        puts "https://tubatuba.net/#{uuid}.png"
    end
end
