# frozen_string_literal: true

# app.rb
require_relative 'authentication'

# Public key
KEY_PATH = '../keys-storage/rsa/key1.pub.pem'

before do
  content_type :json
  authenticate_user!
end

def username
  @user.username
end

def authenticate_user!
  token = request.env['HTTP_AUTHORIZATION']
  raise 'Missing token' if token.nil?

  auth = Authentication.new(KEY_PATH)
  @user = auth.verify!(token)
rescue StandardError => e
  halt 404, { error: e }.to_json
end

get '/calc/add' do
  res = params[:x].to_f + params[:y].to_f
  { user: username, result: format('%0.2f', res) }.to_json
end

get '/calc/mul' do
  res = params[:x].to_f * params[:y].to_f
  { user: username, result: format('%0.2f', res) }.to_json
end

get '/calc/sub' do
  res = params[:x].to_f - params[:y].to_f
  { user: username, result: format('%0.2f', res) }.to_json
end

get '/calc/div' do
  y = params[:y].to_f
  res = if y.zero?
          'INF'
        else
          format('%0.2f', params[:x].to_f / y)
        end
  { user: username, result: res }.to_json
end
