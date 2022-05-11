require 'digest'
require_relative '../database'

class User 
  attr_reader :username, :id, :pwd_digest

  def initialize(id, username, pwd_digest)
    @id = id
    @username = username
    @pwd_digest = pwd_digest
  end

  def authenticate(password)
    User.digest(password) == pwd_digest
  end

  def self.find_by_username(username) 
    record = db_table.find{ |record| record[:username] == username }
    new(record[:id], record[:username], record[:pwd_digest]) unless record.nil?
  end

  def self.find_by_id(id) 
    record = db_table.find{ |record| record[:id] == id }
    new(record[:id], record[:username], record[:pwd_digest]) unless record.nil?
  end

  def self.db_table
    Database.users
  end

  def self.digest(password)
    Digest::SHA2.hexdigest(password)
  end
end
