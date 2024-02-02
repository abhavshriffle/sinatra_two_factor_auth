class ApplicationController < ActiveRecord::Base
  enable :sessions

  helpers do
    def authenticate
      username = params[:username]
      User.find_by(username: username)
    end

    def current_user
      User.find_by(id: session[:user_id])
    end

    def logged_in?
      current_user.present?
    end
  end

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
  end
end
