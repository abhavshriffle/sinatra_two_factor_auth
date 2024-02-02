class AddOtpAndAuthenticationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp, :string
    add_column :users, :authentication, :boolean, default: false
    add_column :users, :two_factor_auth, :boolean, default: false
  end
end
