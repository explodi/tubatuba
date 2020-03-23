class SecurityCamera < ApplicationRecord
    def image_url
        return "http://#{self.ip_str}:#{self.port}/cam_1.jpg"
    end
end
