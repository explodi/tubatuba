class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :check_timers
    def check_timers
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
