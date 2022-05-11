# config.ru

require 'bundler/setup'
Bundler.require
require File.join(File.dirname(__FILE__), 'app.rb')

run Sinatra::Application
