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
    def events_update
        @event=Event.find(params[:id])
        @event.name=params[:name]
        puts params[:start]
        @event.start=params[:start]
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
