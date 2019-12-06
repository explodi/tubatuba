class Event < ApplicationRecord
    def acts
        return EventAct.where({:event_id=>self.id})
    end
    def screenshot
        command="google-chrome --headless --enable-logging --disable-gpu --no-sandbox --screenshot=\"#{Rails.root.join('public')}/screen.png\" \"https://www.tubatuba.net/\""
        puts command
        system(command)
    end
end
