class TC_UserTest < Test::Unit::TestCase
  include AppTestCase

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
      "user1:",
      "  attributes:",
      "    mail: user1@example.com",
      '    public_key: "abcdef"',
      "    is_admin: false",
      "    is_restricted: true",
      "  usergroups:",
      "user2:",
      "  attributes:",
      "    mail: user2@example.com",
      '    public_key: "zyxwvu"',
      "    is_admin: true",
      "    is_restricted: false",
      "  usergroups:",
      ""
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

    expected = [
      "Error while saving user",
      "name has already been taken",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
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
      "    mail: user1@example.com",
      '    public_key: "abcdef"',
      "    is_admin: false",
      "    is_restricted: true",
      "  usergroups:",
      ""
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
      "  mail: String",
      "  public_key: Text",
      "  is_admin: Boolean",
      "  is_restricted: Boolean",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
  end

  def test_getting_an_user_edit_form
    ensure_users_are_present

    get '/users/edit/user1'
    assert last_response.ok?

    expected = [
      "user:",
      "  mail: String",
      "  public_key: Text",
      "  is_admin: Boolean",
      "  is_restricted: Boolean",
      "data:",
      "  name: user1",
      "  mail: user1@example.com",
      "  public_key: abcdef",
      "  is_admin: false",
      "  is_restricted: true",
      ""
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
    ensure_users_are_present

    delete '/users/user1'
    assert last_response.redirection?
    assert_equal 'User removed', last_response.body
  end

  def test_deleting_a_user_with_post
    ensure_users_are_present

    post '/users/user1', :_method => 'delete'
    assert last_response.redirection?
    assert_equal 'User removed', last_response.body
  end

  private

  def ensure_users_are_present
    ensure_no_user_is_present

    User.create({
      :name       => 'user1',
      :mail       => 'user1@example.com',
      :public_key => 'abcdef'
    })
    User.create({
      :name          => 'user2',
      :mail          => 'user2@example.com',
      :public_key    => 'zyxwvu',
      :is_admin      => true,
      :is_restricted => false
    })
  end

  def ensure_no_user_is_present
    User.destroy_all
  end
end