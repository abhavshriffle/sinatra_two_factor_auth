require 'pony'

class UserMailer < ActionMailer::Base
  default from: 'abhav@shriffle.com'

  def self.welcome_email(user)
    Pony.mail({
      to: user.email,
      subject: 'Welcome to YourApp!',
      body: 'Welcome to YourApp! Please confirm your registration.',
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        user_name: 'abhav@shriffle.com',
        password: 'omsbcyzgksejgbvf',
        authentication: :plain,
        enable_starttls_auto: true,
        open_timeout: 130,
        read_timeout: 130
      }
    })
  end

  def self.generate_otp_email(user)
     one_time_code = SecureRandom.hex(3).upcase
     Pony.mail(
       to: user.email,
       subject: 'Your One-Time Code for Authentication',
       body: "Your one-time code is: #{one_time_code}",
       via: :smtp,
       via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        user_name: 'abhav@shriffle.com',
        password: 'omsbcyzgksejgbvf',
        authentication: :plain,
        enable_starttls_auto: true,
        open_timeout: 130,
        read_timeout: 130
       }
     )
     one_time_code
  end

  def update_last_one_time_code(user, code)
    user.update(otp: code)
  end
end
