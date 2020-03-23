class SecurityCamerasController < ApplicationController
    def feed
        require 'open-uri'
        require 'fileutils'

        current_camera_key="current:camera"
        camera_cycle_timer="camera:timer"
        @camera=nil
        if REDIS.exists(current_camera_key) 
            if SecurityCamera.exists?(REDIS.get(current_camera_key))
                @camera=SecurityCamera.find(REDIS.get(current_camera_key))
                puts "[current camera] #{@camera.inspect}" 
            else
                REDIS.del(current_camera_key)
            end
        end
        if !@camera
            @last_seen_camera=SecurityCamera.order("last_seen DESC").first
            if @last_seen_camera 
                puts @last_seen_camera.inspect
                if @last_seen_camera.save_image
                    REDIS.set(current_camera_key,@last_seen_camera.id)
                    @camera=@last_seen_camera
                else
                    REDIS.del(current_camera_key)
                end
            end
        end
        if !@camera
            offset = rand(SecurityCamera.count) 
            @random_camera=SecurityCamera.offset(offset).first
            puts @random_camera.inspect
            if @random_camera.save_image
                @camera=@random_camera
                REDIS.set(current_camera_key,@random_camera.id)
            end
        end
        if !REDIS.exists(camera_cycle_timer)
            if Rails.env.production?
                FindNewCurrentCameraJob.perform_later 
            else
                FindNewCurrentCameraJob.perform_now 
            end
        #     offset = rand(SecurityCamera.count)
        #     @random_camera=SecurityCamera.offset(offset).first
        #     if @random_camera.save_image
        #         @camera=@random_camera
        #         REDIS.set(current_camera_key,@random_camera.id)
        #     end
        #     REDIS.set(camera_cycle_timer,"1")
        #     REDIS.expire(camera_cycle_timer,10)
        end
        if @camera
            if !@camera.last_camera_image
                puts "[find new camera]"
                if Rails.env.production?
                    FindNewCurrentCameraJob.perform_later 
                else
                    FindNewCurrentCameraJob.perform_now 
                end
            end
            if !REDIS.exists("screenshot:timer")
                REDIS.set("screenshot:timer","1")
                REDIS.expire("screenshot:timer",60)
                if Rails.env.production?
                    CameraImageJob.perform_later @camera
                else
                    CameraImageJob.perform_now @camera
                end
            end
            redirect_to @camera.last_camera_image_url
        else
            render :plain => "WAIT"

        end
    end
end
