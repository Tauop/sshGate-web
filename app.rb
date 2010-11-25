require 'erb'

require 'rubygems'
require 'bundler'
Bundler.require

$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'sinatra/rest_api'

#
# Configuration section
# http://sinatra-book.gittr.com/#configuration
#
configure do
  # ensuring the root path is set
  set :root, File.dirname(__FILE__)

  # defining the yaml mime type
  # TODO: after devel set to 'text/yaml'
  mime_type :yaml, 'text/plain'

  # allowing usage of <%- ... -%> tags
  set :erb, :trim => '-'

  # allowing usage of _method for PUT and DELETE methods
  set :method_override, true

  # do not display exceptions to users
  set :show_exceptions, false

  # ensure the views location (bundler or passenger bugs happen)
  set :views, './views'

  config_file 'sshgate.yml'

  # Loading the database
  ActiveRecord::Base.establish_connection(settings.database[settings.environment.to_sym])
end



#
# User model
#
class User < ActiveRecord::Base
  validates_uniqueness_of :name

  before_update :remove_name

  def restricted?
    !self.is_restricted.zero?
  end

  private

  def remove_name
    if self.name_changed?
      self.name = self.name_was
    end
  end
end



#
# Called before each action
# http://sinatra-book.gittr.com/#filters
#
before do
  # setting the content-type to yaml
  content_type :yaml
end

resources :user, :key => :name

# Responding to a non existing URL
not_found do
  unless response.body.is_a?(String)
    throw :halt, [404, 'Command not found']
  end
end
