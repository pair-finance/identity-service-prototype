# frozen_string_literal: true

require 'digest'

# Imitates a real database
class Database
  def self.users
    [
      { id: '40e6215d-b5c6-4896-987c-f30f3678f608', username: 'foo@example.com', pwd_digest: digest('abc123') },
      { id: '6ecd8c99-4036-403d-bf84-cf8400f67836', username: 'bar@example.com', pwd_digest: digest('xyz789') },
      { id: '3f333df6-90a4-4fda-8dd3-9485d27cee36', username: 'baz@example.com', pwd_digest: digest('foobar') }
    ]
  end

  def self.digest(password)
    Digest::SHA2.hexdigest(password)
  end
end

