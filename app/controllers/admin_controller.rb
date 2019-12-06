class AdminController < ApplicationController
    before_action :check_admin_permissions
    skip_before_action :verify_authenticity_token
    layout "admin"
    def dashboard
        redirect_to "/admin/events/index"
    end
    def check_admin_permissions
        if !current_user 
            redirect_to "/login"
        end
    end
    def events_index
        @deleted=false
        @category="next"
        if params[:category]
            @category=params[:category] 
            @deleted=true if params[:category]=="deleted"
        end
        @events=Event.where(:deleted=>@deleted)
    end
    def events_create
        @event=Event.new({:name=>params[:name]})
        @event.save
        redirect_to "/admin/events/edit/#{@event.id}"
    end
    def events_edit
        @event=Event.find(params[:id])
    end
    def acts_create
        @event=Event.find(params[:id])
        @act=EventAct.new(:event_id=>@event.id,:name=>params[:name])
        @act.save
        render :json=>@event.acts
    end
    def acts_index
        @event=Event.find(params[:id])
        render :json=>@event.acts
    end
    def acts_destroy
        @act=EventAct.find(params[:id])
        @event=Event.find(@act.event_id)
        @act.destroy
        render :json=>@event.acts
    end
    def events_update
        @event=Event.find(params[:id])
        @event.name=params[:name]
        @event.background_url=params[:background_url]
        @event.text_color=params[:text_color]

        event_start=@event.start
        event_end=@event.end
        if params[:start_changed]=="true"
            event_start=DateTime.parse(params[:start]).in_time_zone("America/Santiago")
            event_start_offset=(event_start.utc_offset)/60/60
            event_start=(event_start-event_start_offset.hours).utc

            puts event_start
        end
        if params[:end_changed]=="true"
            event_end=DateTime.parse(params[:end]).in_time_zone("America/Santiago")
            event_end_offset=(event_end.utc_offset)/60/60
            event_end=(event_end-event_end_offset.hours).utc

            puts event_end
        end

        if event_end<event_start
            flash[:error]="event cannot start after it ends"
        else
            @event.start=event_start
            @event.end=event_end
        end
        @event.save
        redirect_to "/admin/events/edit/#{@event.id}"
    end
    def events_destroy
        @event=Event.find(params[:id])
        @event.update_attribute(:deleted,true)
        @event.save
        redirect_to "/admin/events/index"

    end
    def events_recover
        @event=Event.find(params[:id])
        @event.update_attribute(:deleted,false)
        @event.save
        redirect_to "/admin/events/index?category=deleted"

    end
end
