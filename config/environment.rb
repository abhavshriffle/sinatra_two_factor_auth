ENV['SINATRA_ENV'] ||= 'development'

require 'bundler/setup'
require 'action_mailer'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: "db/#{ENV['SINATRA_ENV']}.pg"
)

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: 'smtp.example.com',
  port: 587,
  user_name: 'abhav@shriffle.com',
  password: '1234',
  enable_starttls_auto: true,
  authentication: :plain
}

require_all 'app'
