class LivestreamsController < ApplicationController
    def create
        puts params.inspect
        return :json=>{:success=>true}
    end
    def destroy
        puts params.inspect
        return :json=>{:success=>true}
    end
end
