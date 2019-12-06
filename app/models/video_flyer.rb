class VideoFlyer < ApplicationRecord
    def url
        return "/videos/#{self.uuid}.webm"
    end
    def status
        url="http://#{ENV['TUBAFLYER_PORT_8383_TCP_ADDR']}:#{ENV['TUBAFLYER_PORT_8383_TCP_PORT']}/status"
        puts url    
 
        response=RestClient.post url, {:uuid=>self.uuid}
        puts response.body
        if JSON.parse(response.body)["complete"]
            
            return "complete"
        elsif JSON.parse(response.body)["progress"].to_i>0
            return "#{JSON.parse(response.body)["progress"]}% complete"
        else
            return "in queue"
        end
    end
end
