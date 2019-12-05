class UsersController < ApplicationController
    def new
      if !current_user
        redirect_to "/login"
      end
    end
    
    def create
      if current_user
        user = User.new(user_params)
        if user.save
          session[:user_id] = user.id
          redirect_to '/'
        else
          redirect_to '/signup'
        end
      else
        redirect_to "/login"
      end
    end
end
