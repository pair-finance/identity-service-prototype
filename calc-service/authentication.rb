# frozen_string_literal: true

require 'openssl'
require 'jwt'
require_relative 'user'

# Verifies jwt using a public key
class Authentication
  attr_reader :key_path

  def initialize(key_path)
    @key_path = key_path
  end

  def verify!(token)
    token = JWT.decode(token, public_key, true, { algorithm: 'RS256' }).first
    user = User.find_by_id(token['user_id'])
    
    raise 'User not found' if user.nil?

    user
  end

  private

  def public_key
    @public_key ||= OpenSSL::PKey::RSA.new(File.read(key_path))
  end
end
