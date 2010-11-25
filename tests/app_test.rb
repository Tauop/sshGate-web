require 'yaml'
require 'app'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_empty_response_at_beginning
    ensure_no_user_is_present

    get '/users'
    assert last_response.ok?
    assert last_response.body.empty?
  end

  def test_getting_all_users
    ensure_users_are_present

    get '/users'
    assert last_response.ok?
    
    expected = [
      "- user1:",
      "  attributes:",
      "    is_restricted: true",
      "- user2:",
      "  attributes:",
      "    is_restricted: false\n"
    ].join("\n")
    
    assert_equal expected, last_response.body
  end

  def test_creating_a_user
    post '/users', :user => { :name => 'user-test1' }
    assert last_response.redirection?
    assert_equal 'User created', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/users/user-test1', last_request.url
    assert last_response.ok?
  end

  def test_creating_a_user_with_existing_name_should_not_work
    ensure_users_are_present
    post '/users', :user => { :name => 'user1' }
    assert_equal 'Error while saving User', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/users/new', last_request.url
    assert last_response.ok?
  end

  def test_getting_a_user
    ensure_users_are_present

    get '/users/user1'
    assert last_response.ok?

    expected = [
      "user1:",
      "  attributes:",
      "    is_restricted: true\n"
    ].join("\n")

    assert_equal expected, last_response.body
  end

  def test_getting_an_unexisting_user_should_not_work
    get '/users/not-existing-user'
    assert last_response.not_found?
    assert_equal "User not found", last_response.body
  end

  def test_getting_the_new_user_infos
    get '/users/new'
    assert last_response.ok?

    expected = [
      "user:",
      "  name: String",
      "  is_restricted: Boolean\n"
    ].join("\n")

    assert_equal expected, last_response.body
  end

  def test_getting_an_edit_form
    ensure_users_are_present

    get '/users/edit/user1'
    assert last_response.ok?

    expected = [
      "user:",
      "  is_restricted: Boolean",
      "data:",
      "  name: user1",
      "  is_restricted: true\n"
    ].join("\n")

    assert_equal expected, last_response.body
  end

  def test_updating_a_users_name_should_not_work
    ensure_users_are_present

    put '/users/user1', :user => { :name => 'user42' }
    assert last_response.redirection?
    assert_equal 'User updated', last_response.body

    get '/users/user42'
    assert last_response.not_found?
  end

  def test_updating_a_users_restriction_with_put
    put '/users/user1', :user => { :is_restricted => 0 }
    assert last_response.redirection?
    assert_equal 'User updated', last_response.body
  end

  def test_updating_a_users_restriction_with_post
    post '/users/user1', :user => { :is_restricted => 1 }, :_method => 'put'
    assert last_response.redirection?
    assert_equal 'User updated', last_response.body
  end

  def test_deleting_a_user
    delete '/users/user1'
    assert last_response.redirection?
    assert_equal 'User removed', last_response.body
  end

  def test_calling_an_undefined_url
    get '/not-existing-url'
    assert last_response.not_found?
    assert_equal 'Command not found', last_response.body
  end

  private

  def ensure_users_are_present
    ensure_no_user_is_present
    User.find_or_create_by_name('user1')
    User.find_or_create_by_name_and_is_restricted('user2', false)
  end

  def ensure_no_user_is_present
    User.destroy_all
  end
end
