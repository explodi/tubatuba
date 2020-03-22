class LivestreamsController < ApplicationController
    skip_before_action :verify_authenticity_token
    def show
        if Rails.env.development?
            return :json=>true
        else
            if Livestream.exists?({:started=>true,:ended=>false})
                return :json=>true
            else
                return :json=>false
            end
        end
    end
    def create
        puts params.inspect
        rails "BadKey" if params[:name]!="911ChicoTerry"
        @livestream=Livestream.find_or_create_by({:started=>false,:ended=>false})
        if !@livestream.uuid
            @livestream.uuid=SecureRandom.uuid
            @livestream.save
        end
        puts "[livestream url key] #{@livestream.uuid}"
        response.set_header('Location', "hack-the-planet")
   
        render :plain => "", :status => 304
        return :json=>{:success=>true}
    end
    def destroy
        puts params.inspect
        @livestream=Livestream.find_or_create_by({:started=>true,:ended=>false})
        @livestream.update_attribute(:ended,true)
        return :json=>{:success=>true}
    end
end
