ENV['RACK_ENV'] = 'test'

require 'yaml'
require 'app'
require 'test/unit'
require 'rack/test'

module AppTestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def yaml_load(str)
    YAML.load(str)
  end
  alias :y :yaml_load
end

require 'tests/tc_application_test'

Dir['tests/resources/*.rb'].each do |t|
  require t
end
