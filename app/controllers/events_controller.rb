class EventsController < ApplicationController
    def index
        @events=Event.where(:deleted=>false)
    end
    def admin
        if !current_user
            redirect_to "/login"
        else
            @events=Event.all

        end
    end
end
