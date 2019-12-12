class RadioController < ApplicationController
    def current_song
        render :json=>Radio.current_song
    end
end
