class LivestreamsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def show
        if Rails.env.development?
            render :json=>true
        else
            if Livestream.exists?({:started=>true,:ended=>false})
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
   
        render :plain => "", :status => 304
    end
    def destroy
        puts params.inspect
        @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        @livestream.update_attribute(:ended,true)
        render :json=>{:success=>true}
    end
end
