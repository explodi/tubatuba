require 'mimemagic'

class AdminController < ApplicationController
    before_action :check_admin_permissions
    skip_before_action :verify_authenticity_token

    def dashboard
        redirect_to "/admin/songs/index"
    end
    def check_admin_permissions
        if !current_user 
            redirect_to "/login"
        end
    end
    def events_index
        @deleted=false
        @category="next"
        @events=Event.next_events

        if params[:category]
            @category=params[:category] 
            if params[:category]=="deleted"
                @events=Event.where(:deleted=>true)
            elsif params[:category]=="past"
                @events=Event.where("'end' < ?",DateTime.now).where(:deleted=>false)
            end
        end
    end
    def video_formats_index
        @video_formats=VideoFormat.all
    end
    def video_formats_destroy
        VideoFormat.find(params[:id]).destroy
        redirect_to "/admin/video_formats/index"
    end
    def video_formats_create
        @video_format=VideoFormat.new({:name=>params[:name],:width=>params[:width],:height=>params[:height],:title=>false,:line_up=>false,:address=>false,:date=>false})
        puts params.inspect
        @video_format.title=true if params[:title]=="true"
        @video_format.line_up=true if params[:line_up]=="true"
        @video_format.address=true if params[:address]=="true"
        @video_format.date=true if params[:date]=="true"
        @video_format.video_enabled=true if params[:video_enabled]=="true"
        @video_format.save
        Event.next_events.each do |event|
            CreateFlyersJob.perform_later event
            CreateVideosJob.perform_later event
        end
        redirect_to "/admin/video_formats/index"
    end
    def events_create
        if params[:start]=="" || params[:end]==""
            flash[:error] = "Invalid Dates"
            redirect_to "/admin/events/new"
        else
            event_start=DateTime.parse(params[:start])
            # event_start=DateTime.parse(params[:start]).in_time_zone("America/Santiago")
            # event_start_offset=(event_start.utc_offset)/60/60
            # event_start=(event_start-event_start_offset.hours).utc
            puts event_start.inspect
            event_end=DateTime.parse(params[:end])
            # event_end=DateTime.parse(params[:end]).in_time_zone("America/Santiago")
            # event_end_offset=(event_end.utc_offset)/60/60
            # event_end=(event_end-event_end_offset.hours).utc
            puts event_end.inspect
            
            if event_start>event_end
                flash[:error] = "Event start> Event End"
                redirect_to "/admin/events/new"
            elsif event_start<DateTime.now
                flash[:error] = "Event start < now"
                redirect_to "/admin/events/new"
            else
                @event=Event.new({:name=>params[:name],:text_color=>'white',:title_color=>'white',:start=>event_start,:end=>event_end,:version=>SecureRandom.hex})
                @event.image_hash=SecureRandom.hex
                @event.save
                @event.generate_url_id
                redirect_to "/admin/events/edit/#{@event.id}"
            end
        end
    end
    def events_edit
        @event=Event.find(params[:id])
        @video_format=VideoFormat.all.first
        @video_format=VideoFormat.find(params[:vf]) if params[:vf]
        puts @video_format.inspect
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
    def songs_upvote
        @song=Song.find(params[:id])
        render :json=>{:success=>@song.update_attribute(:score,2)}
    end
    def songs_downvote
        @song=Song.find(params[:id])
        render :json=>{:success=>@song.update_attribute(:score,0)}
    end
    def songs_new

    end
    def songs_create
        mime=MimeMagic.by_path(params[:file].tempfile.path)
        puts "[file] #{mime.type}"
        if mime.type=="audio/mpeg"
            md5=Digest::MD5.file(params[:file].tempfile.path).hexdigest
            if !Song.find_by_md5(params[:md5])
                params[:file].rewind
                unless File.directory?(Rails.root.join("radio"))
                    FileUtils.mkdir_p(Rails.root.join("radio"))
                end
                FileUtils.cp(params[:file].tempfile.path,Rails.root.join("radio","#{md5}.mp3"))
                FileUtils.chmod(777,Rails.root.join("radio","#{md5}.mp3"))
                @song=Song.new({:md5=>md5})
                @song.save
                @song.find_info
                MPD_CLIENT.connect? if !MPD_CLIENT.connected?
                MPD_CLIENT.send_command('rescan')
            else
                puts "[file] md5 already exists: #{md5}"
            end
        end
        render :json=>{:success=>true}
    end
    def songs_index
        @songs=Song.all
    end
    def users_index
        @users=User.all
    end
    def users_create
        @user=User.new({:email=>params[:email],:password=>params[:password],:password_confirmation=>params[:password]})
        @user.save
        redirect_to "/admin/users/index"
    end
    def songs_destroy
        @song=Song.find(params[:id])

        FileUtils.rm(Rails.root.join("radio","#{@song.md5}.mp3")) if @song.file_exists
        @song.destroy
        redirect_to "/admin/songs/index"
    end
    def events_update
        @event=Event.find(params[:id])
        @event.name=params[:name]
        @event.text_color=params[:text_color]
        @event.eventbrite_url=params[:eventbrite_url]
        @event.title_color=params[:title_color]
        @event.image_hash=SecureRandom.hex
        @event.version=SecureRandom.hex

        if params[:live]=="true"
            @event.live=true
        else
            @event.live=false
        end
        if params[:mp3]
            mime=MimeMagic.by_path(params[:mp3].tempfile.path)
            FileUtils.cp(params[:mp3].tempfile.path,Rails.root.join("public","audio","#{@event.id}.mp3")) if mime.type=="audio/mpeg"
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
        # if params[:start_changed]=="true"
            # event_start=DateTime.parse(params[:start]).in_time_zone("America/Santiago")
            # event_start_offset=(event_start.utc_offset)/60/60
            # event_start=(event_start-event_start_offset.hours).utc
            event_start=DateTime.parse(params[:start])

            puts event_start
        # end
        # if params[:end_changed]=="true"
        #     event_end=DateTime.parse(params[:end]).in_time_zone("America/Santiago")
        #     event_end_offset=(event_end.utc_offset)/60/60
        #     event_end=(event_end-event_end_offset.hours).utc
            event_end=DateTime.parse(params[:end])

            puts event_end
        # end

        if event_end&&event_start&&event_end<event_start
            flash[:error]="event cannot start after it ends"
        else
            @event.start=event_start
            @event.end=event_end
        end
        @event.save
        # CreateFlyersJob.perform_later @event
        CreateVideosJob.perform_later @event

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
