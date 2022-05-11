# frozen_string_literal: true

# app.rb
require 'faraday'
require 'json'
require 'logger'
require_relative '../users-service/database'

LOGIN_SERVICE_URL = 'http://localhost:3000'
CALC_SERVICE_URL =  'http://localhost:3001'
USERS_SERVICE_URL =  'http://localhost:3002'
TEMPL_SERVICE_URL =  'http://localhost:3003'



def redis 
  @redis ||= Redis.new
end

def logger
  @logger ||= Logger.new($stdout)
end

def log(msg)
  logger.info(msg)
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

def create_user(username, password, token = nil)
  conn = connection(USERS_SERVICE_URL)

  log("sending create user request to #{USERS_SERVICE_URL}")
  response = conn.post('/create') do |req|
    req.body = { username: username, password: password }.to_json
    req.headers['Authorization'] = token unless token.nil?
  end
  log("received response: #{response.body}")

  body = JSON.parse(response.body)
  body['user_id']
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

def fetch_latest_calc(token = nil)
  conn = connection(TEMPL_SERVICE_URL)

  log("sending latest result request to #{TEMPL_SERVICE_URL}")
  response = conn.get("/latest-calc") do |req|
    req.headers['Authorization'] = token unless token.nil?
  end
  log("received response: #{response.body}")

  body = JSON.parse(response.body)
  body['result']
end


# Various scenarious

# Run all services and list channels `PUBSUB CHANNELS *`
def creating_user
  # Create an admin as a superuser
  Database.create_admin
  # Login as admin
  token = login('admin@example.com', 'admin')
  # Create a normal user
  create_user('foo@example.com', 'abc123', token)
end

def happy_path
  # Create an admin as a superuser
  Database.create_admin
  # Login as admin
  admin_token = login('admin@example.com', 'admin')
  # Create a normal user
  create_user('foo@example.com', 'abc123', admin_token)

  # New user logs in
  token = login('foo@example.com', 'abc123')
  # and invokes calc service
  calculate(3, 5, 'add', token)
  calculate(3, 5, 'mul', token)
  fetch_latest_calc(token)
end

def missing_user
  # Create an admin as a superuser
  Database.create_admin
  # Login as admin
  admin_token = login('admin@example.com', 'admin')
  # Create a normal user
  create_user('foo@example.com', 'abc123', admin_token)

  # A fake user logs in
  token = login('xyzzy@example.com', 'abc123')
  # and invokes calc service
  calculate(3, 5, 'add', token)
end

happy_path
