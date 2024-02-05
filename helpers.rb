require 'rotp'
require 'yaml'

def generate_secret_key(_environment)
  ROTP::Base32.random_base32
end
