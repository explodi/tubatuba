class Livestream < ApplicationRecord
    def self.listener_count
        @current_listener_count=0;
        REDIS.smembers("listener_ips").each do |ip|
          if REDIS.exists("listener:ping:#{ip}")
            @current_listener_count=@current_listener_count+1 
          else
            REDIS.srem("listener_ips",ip)
          end
        end
        return @current_listener_count
    end
end
