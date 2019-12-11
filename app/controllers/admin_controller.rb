class AdminController < ApplicationController
    before_action :check_admin_permissions
    skip_before_action :verify_authenticity_token

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
        @events=Event.where("'end' > ?",DateTime.now)

        if params[:category]
            @category=params[:category] 
            if params[:category]=="deleted"
                @events=Event.where(:deleted=>true)
            elsif params[:category]=="past"
                @events=Event.where("'end' < ?",DateTime.now)
            end
        end
    end
    def events_create
        event_start=DateTime.parse(params[:start]).in_time_zone("America/Santiago")
        event_start_offset=(event_start.utc_offset)/60/60
        event_start=(event_start-event_start_offset.hours).utc
        event_end=DateTime.parse(params[:end]).in_time_zone("America/Santiago")
        event_end_offset=(event_end.utc_offset)/60/60
        event_end=(event_end-event_end_offset.hours).utc
        raise "BadDate" if event_start<event_end || event_start<DateTime.now
        @event=Event.new({:name=>params[:name],:text_color=>'white',:title_color=>'white',:start=>event_start,:end=>event_end})
        
        @event.save
        @event.generate_url_id
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
    def events_videos_create
        @event=Event.find(params[:id])
        @width=params[:width].to_i
        @height=params[:height].to_i
        @frames=3000
        render :json=>{:success=>@event.record_video(@width,@height,@frames)}
    end
    
    def events_videos_index
        @event=Event.find(params[:id])
        @videoflyers=VideoFlyer.where({:event_id=>@event.id})
        
    end
    def events_update
        @event=Event.find(params[:id])
        @event.name=params[:name]
        @event.text_color=params[:text_color]
        @event.title_color=params[:title_color]
        if params[:live]=="true"
            @event.live=true
        else
            @event.live=false
        end
        if params[:mp3]
            FileUtils.cp(params[:mp3].tempfile.path,Rails.root.join("public","audio","#{@event.id}.mp3"))
        end
        if params[:background]
            file_name="#{SecureRandom.hex}.gif"
            @event.background_url=file_name
            unless File.directory?(Rails.root.join("public","image"))
                FileUtils.mkdir_p(Rails.root.join("public","image"))
            end
            FileUtils.cp(params[:background].tempfile.path,Rails.root.join("public","image",file_name))
        end
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

        if event_end&&event_start&&event_end<event_start
            flash[:error]="event cannot start after it ends"
        else
            @event.start=event_start
            @event.end=event_end
        end
        @event.save
        CreateVideosJob.perform_later @event
        CreateFlyersJob.perform_later @event

        @event.generate_url_id unless @event.url_id
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
    def events_flyers
        @event=Event.find(params[:id])
        @flyers=[]
        Event.flyer_formats.each do |f|
            flyer=Flyer.where({:event_id=>@event.id,:width=>f[0],:height=>f[1]}).first
            @flyers.push(flyer) if flyer
        end
    end
end
