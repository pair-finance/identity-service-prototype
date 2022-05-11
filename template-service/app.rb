# frozen_string_literal: true

# app.rb
require_relative 'authentication'
require 'redis'
require 'json'
require 'logger'
require_relative 'database'
require_relative '../channels'

# Public key
KEY_PATH = '../keys-storage/rsa/key1.pub.pem'

before do
  content_type :json
  authenticate_user!
end

def redis 
  @redis ||= Redis.new
end

def logger 
  @logger ||= Logger.new($stdout)
end

def authenticate_user!
  token = request.env['HTTP_AUTHORIZATION']
  raise 'Missing token' if token.nil?

  auth = Authentication.new(KEY_PATH)
  @user = auth.verify!(token)
rescue StandardError => e
  halt 404, { error: e }.to_json
end


Thread.new do
  redis.subscribe(USERS_CHANNEL) do |on|
    on.subscribe do |channel, subscriptions|
    logger.info "Template Service Subscribed to ##{channel} (#{subscriptions} subscriptions)"
    end
    on.message do |channel, msg|
      logger.info "Got #{msg} on channel ##{channel}"
      data = JSON.parse(msg)
      
      Database::User.create!(id: data['user_id'], pwd_digest: data['pwd_digest'])
    end
  end
end

get '/latest-calc' do
  { result: redis.get('latest-calc') }.to_json
end




