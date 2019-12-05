class AdminController < ApplicationController
    before_action :check_admin_permissions
    skip_before_action :verify_authenticity_token
    layout "admin"

    def check_admin_permissions
        if !current_user 
            redirect_to "/login"
        end
    end
    def events
        @events=Event.all
    end
end
