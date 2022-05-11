# frozen_string_literal: true

require 'digest'
require 'securerandom'
require 'redis'
require 'json'

PREFIX = 'users'

module Database
  class User
    attr :username, :id, :pwd_digest

    def initialize(id, username, pwd_digest)
      @id = id
      @username = username
      @pwd_digest = pwd_digest
    end

    def authenticate(password)
      Database.digest(password) == pwd_digest
    end

    def to_s
      "User{id: #{id}, username: #{username}, pwd_digets: #{pwd_digest}}"
    end
      
    class << self  
      def create!(attrs={})
        attrs[:id] = SecureRandom.uuid
        attrs[:pwd_digest] = Database.digest(attrs[:password])
        attrs.delete(:password)

        redis.set("#{PREFIX}:#{attrs[:id]}", attrs.to_json)
        redis.set("#{PREFIX}:#{attrs[:username]}", attrs.to_json) unless attrs[:username].nil?

        user = find_by_id(attrs[:id])
        logger.info "Created a new user: #{user}"
        user
      end

      def find_by_id(id) 
        val = redis.get("#{PREFIX}:#{id}")
        unless val.nil?
          record = JSON::parse(val)
          new(record['id'], record['username'], record['pwd_digest']) 
        end
      end

      def find_by_username(username) 
        val = redis.get("#{PREFIX}:#{username}")
        unless val.nil?
          record = JSON::parse(val)
          new(record['id'], record['username'], record['pwd_digest']) 
        end
      end
    end
  end

  def self.digest(password)
    Digest::SHA2.hexdigest(password)
  end

  def self.create_admin
    User.create!(username: 'admin@example.com', password: 'admin')
  end

  def self.clear
    redis.flushall
  end
end

#   def self.users
#     [
#       { id: '40e6215d-b5c6-4896-987c-f30f3678f608', username: 'foo@example.com', pwd_digest: digest('abc123') },
#       { id: '6ecd8c99-4036-403d-bf84-cf8400f67836', username: 'bar@example.com', pwd_digest: digest('xyz789') },
#       { id: '3f333df6-90a4-4fda-8dd3-9485d27cee36', username: 'baz@example.com', pwd_digest: digest('foobar') }
#     ]
#   end

