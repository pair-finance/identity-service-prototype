# frozen_string_literal: true

require 'json'
require_relative 'authentication'

# Private key
KEY_PATH = '../keys-storage/rsa/key1.pem'

before do
  content_type :json
end

post '/login' do
  body = JSON.parse(request.body.read)
  username = body['username']
  password = body['password']

  auth = Authentication.new(KEY_PATH)
  begin
    # Find user, check password, sign and return a jwt
    token = auth.login!(username, password)
    { token: token }.to_json
  rescue StandardError => e
    { error: e }.to_json
  end
end
