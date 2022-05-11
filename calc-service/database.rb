# frozen_string_literal: true

require 'digest'
require 'securerandom'
require 'redis'
require 'json'

PREFIX = "calc:users".freeze

module Database
  class User
    attr :id, :pwd_digest

    def initialize(id, pwd_digest)
      @id = id
      @pwd_digest = pwd_digest
    end

    def authenticate(password)
      Database.digest(password) == pwd_digest
    end

    def to_s
      "User{id: #{id}, pwd_digets: #{pwd_digest}}"
    end
      
    class << self  
      def create!(attrs={})
        redis.set("#{PREFIX}:#{attrs[:id]}", attrs.to_json)
        
        user = find_by_id(attrs[:id])
        logger.info "Created a new user: #{user}"
        user
      end

      def find_by_id(id) 
        val = redis.get("#{PREFIX}:#{id}")
        unless val.nil?
          record = JSON::parse(val)
          new(record['id'], record['pwd_digest']) 
        end
      end
    end
  end

  def self.digest(password)
    Digest::SHA2.hexdigest(password)
  end

  def self.clear
    redis.flushall
  end
end
