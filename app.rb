require 'sinatra'
require 'active_record'
require 'sinatra/activerecord'
require 'bcrypt'
require 'byebug'
require 'json'
require 'action_mailer'
require 'mail'
require './app/mailers/user_mailer'
require 'securerandom'
require 'letter_opener'
require 'pony'
require 'rotp'
require 'rubocop'
require_relative 'app/mailers/user_mailer'
require_relative 'app/models/user'

configure do
  set :database_file, 'config/database.yml'
end

configure :production do
end

Mail.defaults do
  if Sinatra::Base.development?
    delivery_method LetterOpener::DeliveryMethod, location: File.expand_path('tmp/letter_opener', __dir__)
  else
    delivery_method :smtp, {
      address: 'smtp.example.com',
      port: 587,
      user_name: 'your_username',
      password: 'your_password',
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end
end

post '/register' do
  content_type :json

  begin
    user = User.create(
      username: params[:username],
      email: params[:email],
      password_digest: params[:password_digest]
    )
    UserMailer.welcome_email(user)
    { message: 'Registration successful', user_id: user.id, user_username: user.username,
      user_email: user.email }.to_json
  rescue ActiveRecord::RecordInvalid => e
    status 400
    { error: "Registration failed: #{e.message}" }.to_json
  end
end

post '/login' do
  content_type :json

  user = User.find_by(email: params[:email])
  if user && BCrypt::Password.create(user.password_digest) == params[:password_digest]
    user.update(authentication: true)
    { message: 'Login successful' }.to_json
  else
    status 401
    { error: 'Invalid email or password' }.to_json
  end
end

post '/enable_2fa' do
  content_type :json

  user = User.find_by(email: params[:email])
  two_factor_auth = params[:two_factor_auth]
  if user.present?
    if params[:two_factor_auth]
      user.update(two_factor_auth: true)
      UserMailer.generate_otp_email(user)
      secret_key = ROTP::Base32.random_base32
      { message: 'Two-factor authentication enabled successfully', secret_key:,
        two_factor_auth: 'true' }.to_json
    else
      { error: 'Two-factor authentication is already enabled for this user' }.to_json
    end
  else
    status 404
    { error: 'User not found' }.to_json
  end
end

post '/login_2fa' do
  content_type :json

  user = User.find_by(email: params[:email])
  otp = params[:otp]

  if user.present?
    UserMailer.new.update_last_one_time_code(user, otp)
    if user.two_factor_auth == true && otp == user.otp
      { message: 'Login successful with two-factor' }.to_json
    else
      status 401
      { error: 'Invalid one-time code' }.to_json
    end
  else
    status 404
    { error: 'User not found' }.to_json
  end
end

delete '/logout' do
  content_type :json

  user = User.find_by(email: params[:email])
  if user.nil?
    status 401
    { error: 'User not found' }.to_json
  elsif user.authentication
    user.update(authentication: false)
    { message: 'Logout successful' }.to_json
  else
    { message: 'User already logged out. Log in again to logout.' }.to_json
  end
end

post '/update_password' do
  content_type :json

  user = User.find_by(email: params[:email])
  if user.present?
    user.update(password_digest: params[:new_password_digest])
    { message: 'Password updated successfully' }.to_json
  else
    status 401
    { error: 'Invalid current password' }.to_json
  end
end

post '/disable_2fa' do
  content_type :json

  user = User.find_by(email: params[:email])
  if user.present? && user.two_factor_auth == true
    user.update(two_factor_auth: false)
    { message: 'Two-factor authentication disabled' }.to_json
  else
    status 401
    { error: 'User not found or two-factor authentication not enabled' }.to_json
  end
end
