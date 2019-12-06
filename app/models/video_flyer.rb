class VideoFlyer < ApplicationRecord
    def url
        return "/video/#{self.uuid}.#{self.format_string}"
    end
    def status
        url="http://tubaflyer:8383/status"
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
