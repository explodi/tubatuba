class EventsController < ApplicationController
    def index
        @event=Event.next_event
        redirect_to @event.eventbrite_url if @event && @event.eventbrite_url
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
        @vf=nil
        if params[:format_id]
            puts params[:format_id]
            @vf=VideoFormat.find_by_id(params[:format_id])
            puts @vf.inspect
        end
        render :layout => false

    end
    def ad
        @event=Event.find_by_id(params[:id])
        
    end
end
