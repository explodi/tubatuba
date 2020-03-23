class LivestreamsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def show
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
        @livestream.save
        puts "[livestream url key] #{@livestream.uuid}"
        response.set_header('Location', "hack-the-planet")
        REDIS.set("live_buffering","1")
        REDIS.del("live_online")
        REDIS.expire("live_buffering",200)
        render :plain => "", :status => 304
    end
    def destroy
        puts params.inspect
        @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        @livestream.update_attribute(:ended,true)
        REDIS.del("live_buffering")
        REDIS.del("live_online")
        render :json=>{:success=>true}
    end
end
