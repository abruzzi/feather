require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'sinatra'
require 'rack/test'
require 'rspec'
require 'factory_girl'

set :environment, :test

FactoryGirl.find_definitions

RSpec.configure do |config|
    config.before(:each) { DataMapper.auto_migrate! }
end
