class Flyer < ApplicationRecord
    def url
        return "/#{self.uuid}.png"
    end
end
