class Event < ApplicationRecord
    def acts
        return EventAct.where({:event_id=>self.id})
    end
end
