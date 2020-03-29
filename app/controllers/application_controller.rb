class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :check_timers
    
    def check_timers
      @user_ip=nil
      @user_ip=request.remote_ip if request.remote_ip
      @user_ip=request.ip if request.ip
      @user_ip=request.env['HTTP_X_FORWARDED_FOR'] if request.env['HTTP_X_FORWARDED_FOR'] 
      @user_ip=request.env['HTTP_CF_CONNECTING_IP'] if request.env['HTTP_CF_CONNECTING_IP'] 
      if @user_ip
        puts @user_ip
        REDIS.sadd("listener_ips",@user_ip)
        @listener_ip_cache_key="listener:ping:#{@user_ip}"
        REDIS.set(@listener_ip_cache_key,"1")
        REDIS.expire(@listener_ip_cache_key,60)
      end
      if REDIS.exists("current:camera") 
        if SecurityCamera.exists?(REDIS.get("current:camera"))
          @current_camera=SecurityCamera.find(REDIS.get("current:camera"))
          if !REDIS.exists("camera:screenshot:timer")
            REDIS.set("camera:screenshot:timer","1")
            REDIS.expire("camera:screenshot:timer",10)
            if Rails.env.production?
              CameraImageJob.perform_later @current_camera
            else
                CameraImageJob.perform_now @current_camera
            end
          end
        else
          REDIS.del(current_camera_key)
          if Rails.env.development?
            FindNewCurrentCameraJob.perform_now
          else
            FindNewCurrentCameraJob.perform_later
          end
        end
      else
        if Rails.env.development?
          FindNewCurrentCameraJob.perform_now
        else
          FindNewCurrentCameraJob.perform_later
        end
      end
      ping_key="ping:stream:timer"
      if REDIS.exists(ping_key)==false
          REDIS.set(ping_key,"1")
          REDIS.expire(ping_key,60)
          if Rails.env.development?
              PingLivestreamJob.perform_now
          else
              PingLivestreamJob.perform_later
          end
      end
      camera_timer="camera:get:timer"
      if REDIS.exists(camera_timer)==false
        REDIS.set(camera_timer,"1")
        REDIS.expire(camera_timer,300)
        GetCamerasJob.perform_later
      end
    end

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
end
