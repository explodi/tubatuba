class EventsController < ApplicationController
    def index
        @event=Event.where(:deleted=>false).where(:live=>true).order("id DESC").first
    end
    def admin
        if !current_user
            redirect_to "/login"
        else
            @events=Event.all

        end
    end
    def show
        @event=Event.find_by_url_id(params[:id])
    end
    def ad
        @event=Event.find_by_id(params[:id])
    end
end
