class User < ActiveRecord::Base
  include BCrypt
  has_secure_password
  validates_presence_of :username, :email
  validates_presence_of :password_digest
end
