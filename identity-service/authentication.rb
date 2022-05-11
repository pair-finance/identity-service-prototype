# frozen_string_literal: true

require 'openssl'
require 'jwt'
require_relative '../users-service/database'

# Authenticates a user against a database
# and signs a jwt using a private key
class Authentication
  attr_reader :key_path

  def initialize(key_path)
    @key_path = key_path
  end

  def login!(username, password)
    user = Database::User.find_by_username(username)
    raise 'User not found' if user.nil?
    
    raise 'Wrong user name and password' unless user.authenticate(password)

    JWT.encode(payload(user), private_key, 'RS256')
  end

  private

  def payload(user)
    { user_id: user.id }
  end

  def private_key
    @private_key ||= OpenSSL::PKey::RSA.new(File.read(key_path))
  end
end
