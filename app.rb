require 'erb'

require 'rubygems'
require 'bundler'
Bundler.require

# Adding the lib directory to require path
$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'sinatra/rest_api'

###
### Sinatra Application configuration
###

# Configuration section
configure do
  set :root, File.dirname(__FILE__) # ensuring the root path is set
  set :views, './views'             # ensuring the views location

  set :erb, :trim => '-'            # allowing usage of <%- ... -%> tags
  set :method_override, true        # allowing usage of _method for
                                    # PUT and DELETE methods
  set :show_exceptions, false       # do not display exceptions to users

  mime_type :yaml, 'text/plain'     # defining the yaml mime type

  config_file 'sshgate.yml'         # loads sshgate.yml into settings

  # Connecting to the database
  database_infos = settings.database[settings.environment.to_s]
  ActiveRecord::Base.establish_connection(database_infos)
end

# Called before each action
before do
  content_type :yaml                # setting the content-type to yaml
end

###
### Routes
###

# Responding to a non existing URL
not_found do
  unless response.body.is_a?(String)
    throw :halt, [404, 'Command not found']
  end
end

require 'model/user'

resources :user, :key => :name
