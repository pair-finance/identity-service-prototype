# frozen_string_literal: true

# app.rb
require 'redis'
require 'json'
require 'logger'
require_relative 'authentication'
require_relative 'database'
require_relative '../channels'


# Public key
KEY_PATH = '../keys-storage/rsa/key1.pub.pem'

before do
  content_type :json
  authenticate_admin!
end

def redis 
  @redis ||= Redis.new
end

def logger 
  @logger ||= Logger.new($stdout)
end


def authenticate_admin!
  token = request.env['HTTP_AUTHORIZATION']
  raise 'Missing token' if token.nil?

  auth = Authentication.new(KEY_PATH)
  auth.verify!(token)
rescue StandardError => e
  halt 404, { error: e }.to_json
end

post '/create' do
  body = JSON.parse(request.body.read)
  username = body['username']
  password = body['password']
  user = Database::User.create!(username: username, password: password)
  
  # broadcast that a new user has been created
  redis.publish(USERS_CHANNEL, {user_id: "#{user.id}", pwd_digest: "#{user.pwd_digest}"}.to_json)

  { user_id: user.id }.to_json
end

