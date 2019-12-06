class EventsController < ApplicationController
    def index
        @event=Event.where(:deleted=>false).order("id DESC").first
    end
    def admin
        if !current_user
            redirect_to "/login"
        else
            @events=Event.all

        end
    end
end
