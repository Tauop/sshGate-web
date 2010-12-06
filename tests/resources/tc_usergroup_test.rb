class TC_UsergroupgroupTest < Test::Unit::TestCase
  include AppTestCase

  def test_empty_response_at_beginning
    ensure_no_usergroup_is_present

    get '/usergroups'
    assert last_response.ok?
    assert last_response.body.empty?
  end

  def test_getting_all_usergroups
    ensure_usergroups_are_present

    get '/usergroups'
    assert last_response.ok?

    expected = {
      'usergroup1' => {
        'users' => nil
      },
      'usergroup2' => {
        'users' => nil
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_creating_a_usergroup
    post '/usergroups', :usergroup => { :name => 'usergroup-test1' }
    assert last_response.redirection?
    assert_equal 'Usergroup created', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/usergroups/usergroup-test1', last_request.url
    assert last_response.ok?
  end

  def test_creating_a_usergroup_with_existing_name_should_not_work
    ensure_usergroups_are_present

    post '/usergroups', :usergroup => { :name => 'usergroup1' }

    expected = [
      "Error while saving usergroup",
      "name has already been taken",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
    follow_redirect!

    assert_equal 'http://example.org/usergroups/new', last_request.url
    assert last_response.ok?
  end

  def test_getting_a_usergroup
    ensure_usergroups_are_present

    get '/usergroups/usergroup1'
    assert last_response.ok?

    expected = {
      'usergroup1' => {
        'users' => nil
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_an_unexisting_usergroup_should_not_work
    get '/usergroups/not-existing-usergroup'
    assert last_response.not_found?
    assert_equal "Usergroup not found", last_response.body
  end

  def test_getting_the_new_usergroup_infos
    get '/usergroups/new'
    assert last_response.ok?

    expected = {
      'usergroup' => {
        'name' => 'String'
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_an_usergroup_edit_form
    ensure_usergroups_are_present

    get '/usergroups/edit/usergroup1'
    assert last_response.ok?

    expected = {
      'usergroup' => {
        'name' => 'String'
      },
      'data' => {
        'name' => 'usergroup1'
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_updating_a_usergroup_name_with_put
    ensure_usergroups_are_present

    put '/usergroups/usergroup1', :usergroup => { :name => 'usergroup42' }
    assert last_response.redirection?
    assert_equal 'Usergroup updated', last_response.body

    get '/usergroups/usergroup42'
    assert last_response.ok?
  end

  def test_updating_a_usergroup_name_with_post
    ensure_usergroups_are_present

    post '/usergroups/usergroup1', :usergroup => { :name => 'usergroup42' }, :_method => 'put'
    assert last_response.redirection?
    assert_equal 'Usergroup updated', last_response.body

    get '/usergroups/usergroup42'
    assert last_response.ok?
  end

  def test_deleting_a_usergroup
    ensure_usergroups_are_present

    delete '/usergroups/usergroup1'
    assert last_response.redirection?
    assert_equal 'Usergroup removed', last_response.body
  end

  def test_deleting_a_usergroup_with_post
    ensure_usergroups_are_present

    delete '/usergroups/usergroup1'
    assert last_response.redirection?
    assert_equal 'Usergroup removed', last_response.body
  end

  private

  def ensure_usergroups_are_present
    ensure_no_usergroup_is_present
    Usergroup.create({ :name => 'usergroup1' })
    Usergroup.create({ :name => 'usergroup2' })
  end

  def ensure_no_usergroup_is_present
    Usergroup.destroy_all
  end
end