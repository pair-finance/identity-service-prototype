# frozen_string_literal: true

# app.rb
require 'faraday'
require 'json'
require 'logger'

LOGIN_SERVICE_URL = 'http://localhost:3000'
CALC_SERVICE_URL =  'http://localhost:3001'

@logger = Logger.new($stdout)

def log(msg)
  @logger.info(msg)
end

def connection(url)
  Faraday.new(
    url: url,
    headers: { 'Content-Type' => 'application/json' }
  )
end

def login(username, password)
  conn = connection(LOGIN_SERVICE_URL)

  log("sending login request to #{LOGIN_SERVICE_URL}")
  response = conn.post('/login') do |req|
    req.body = { username: username, 'password': password }.to_json
  end
  log("received response: #{response.body}")

  body = JSON.parse(response.body)
  body['token']
end

def calculate(param_x, param_y, operation, token = nil)
  conn = connection(CALC_SERVICE_URL)

  log("sending calc request to #{CALC_SERVICE_URL}")
  response = conn.get("/calc/#{operation}") do |req|
    req.params['x'] = param_x
    req.params['y'] = param_y
    req.headers['Authorization'] = token unless token.nil?
  end
  log("received response: #{response.body}")

  body = JSON.parse(response.body)
  body['result']
end

# Various scenarious

def happy_path
  token = login('bar@example.com', 'xyz789')
  calculate(3, 5, 'add', token)
end

def missing_token
  calculate(3, 5, 'add')
end

def bad_token
  calculate(3, 5, 'add', 'bad-token')
end

def wrong_password
  token = login('bar@example.com', 'xyz78')
  calculate(3, 5, 'add', token) unless token.nil?
end

def missing_user
  token = login('xyzzy@example.com', 'xyz78')
  calculate(3, 5, 'add', token) unless token.nil?
end

missing_user
