require 'redis'
require 'json'
require 'logger'
require_relative 'database'



def redis 
  @redis ||= Redis.new
end

def logger 
  @logger ||= Logger.new($stdout)
end
Database.setup
puts Database::User.find_by_username('admin@example.com')
Database::clear

# Thread.new do
#   redis.subscribe('users') do |on|
#     on.subscribe do |channel, subscriptions|
#       logger.info "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
#     end
#     on.message do |channel, msg|
#         data = JSON.parse(msg)
#         logger.info "##{channel} - [#{data['user']}]: #{data['msg']}"
#     end
#   end
# end
