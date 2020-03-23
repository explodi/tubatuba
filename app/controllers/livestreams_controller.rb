class LivestreamsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def update
        puts params.inspect

        # @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        # @livestream.uuid=SecureRandom.uuid if !@livestream.uuid
        # @livestream.last_ping=DateTime.now
        # @livestream.save

        render :json=>true

    end
    def show
        @user_ip=nil
        @user_ip=request.remote_ip if request.remote_ip
        @user_ip=request.ip if request.ip
        @user_ip=request.env['HTTP_X_FORWARDED_FOR'] if request.env['HTTP_X_FORWARDED_FOR'] 
        @user_ip=request.env['HTTP_CF_CONNECTING_IP'] if request.env['HTTP_CF_CONNECTING_IP'] 
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
        if @user_ip
            # puts @user_ip
            REDIS.sadd("listener_ips",@user_ip)
            @total_listeners=REDIS.scard("listener_ips")
            REDIS.expire("listener_ips",600)
            @listener_ip_cache_key="listener:ping:#{@user_ip}"
            REDIS.set(@listener_ip_cache_key,"1")
            REDIS.expire(@listener_ip_cache_key,60)
            @current_listener_count=0;
            REDIS.smembers("listener_ips").each do |ip|
                @current_listener_count=@current_listener_count+1 if REDIS.exists("listener:ping:#{ip}")
            end

        end
        if Rails.env.development?
            require 'open-uri'
            render :plain=>open("http://tubatuba.net/live").read
        else
            if REDIS.exists("live_buffering")
                puts "[live] buffering"
                render :json=>false
            elsif REDIS.exists("live_online")
                render :json=>true
            elsif Livestream.exists?({:started=>true,:ended=>false})
                REDIS.set("live_online","1")
                REDIS.expire("live_online",60)
                render :json=>true
            else
                render :json=>false
            end
        end
    end
    def create
        puts params.inspect
        rails "BadKey" if params[:name]!="911ChicoTerry"
        @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        @livestream.uuid=SecureRandom.uuid if !@livestream.uuid
        @livestream.last_ping=DateTime.now if !@livestream.last_ping
        @livestream.save
        puts "[livestream url key] #{@livestream.uuid}"
        response.set_header('Location', "hack-the-planet")
        REDIS.set("live_buffering","1")
        REDIS.del("live_online")
        REDIS.expire("live_buffering",30)
        render :plain => "", :status => 304
    end
    def destroy
        puts params.inspect
        # @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        # @livestream.update_attribute(:ended,true)
        PingLivestreamJob.perform_later
        REDIS.del("live_buffering")
        REDIS.del("live_online")
        render :json=>{:success=>true}
    end
end
