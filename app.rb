require 'erb'

require 'rubygems'
require 'bundler'
Bundler.require

#
# Configuration section
# http://sinatra-book.gittr.com/#configuration
#
configure do
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

  # Loading the database
  # TODO: put this in a config file
  ActiveRecord::Base.establish_connection({
    ## mysql
    # :adapter  => 'mysql',
    # :database => '',
    # :username => '',
    # :password => '',
    # :host     => 'localhost',
    # :encoding => 'utf8'
    ## sqlite
    :adapter => 'sqlite3',
    :database => 'sshgate.sqlite'
  })
end



#
# User model
#
class User < ActiveRecord::Base
  def restricted?
    !self.is_restricted.zero?
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

#
# Actions
# http://sinatra-book.gittr.com/#routes
#

# no default route, redirecting to users
get '/' do
  redirect '/users'
end

# Index
get '/users' do
  @users = User.all
  erb :'users/index'
end

# New
get '/users/new' do
  @user = User.new
  erb :'users/new'
end

# Show
get '/users/:name' do
  @user = User.find_by_name(params[:name])

  throw :halt, [404, 'User not found'] unless @user

  erb :'users/user'
end

# Edit
get '/users/edit/:name' do
  @user = User.find_by_name(params[:name])

  throw :halt, [404, 'User not found'] unless @user

  erb :'users/edit'
end

# Create
post '/users' do
  @user = User.new(params[:user])
  if @user.save
    redirect "/users/#{@user.name}", 'User created'
  else
    redirect "/users/new", 'Error while saving user'
  end
end

# Update
put '/users/:name' do
  @user = User.find_by_name(params[:name])

  throw :halt, [404, 'User not found'] unless @user

  @user.update_attributes(params[:user])
  if @user.save
    redirect "/users/#{@user.name}", 'User updated'
  else
    redirect "/users/edit/#{params[:name]}", 'Error while updating user'
  end
end

# Delete
delete '/users/:name' do
  @user = User.find_by_name(params[:name])

  throw :halt, [404, 'User not found'] unless @user

  @user.destroy
  redirect '/users', 'User removed'
end

# Responding to a non existing URL
not_found do
  throw :halt, [404, 'Command not found']
end
