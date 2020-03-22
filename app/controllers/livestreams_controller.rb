class LivestreamsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        puts params.inspect
        puts "[livestream url key] #{@uuid}"
        @uuid=SecureRandom.uuid
        response.set_header('Location', @uuid)
   
        render :plain => "", :status => 304
        return :json=>{:success=>true}
    end
    def destroy
        puts params.inspect
        return :json=>{:success=>true}
    end
end
