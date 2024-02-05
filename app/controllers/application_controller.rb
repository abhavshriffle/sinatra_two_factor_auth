class ApplicationController < ActiveRecord::Base
  enable :sessions

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
  end
end
