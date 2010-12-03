class TC_MembershipTest < Test::Unit::TestCase
  include AppTestCase

  def test_empty_response_at_beginning
    ensure_no_membership_is_present

    get '/memberships'
    assert last_response.ok?
    assert last_response.body.empty?
  end

  def test_getting_all_memberships
    ensure_memberships_are_present

    get '/memberships'
    assert last_response.ok?

    expected = {
      @membership1.id => {
        'attributes' => {
          'user'      => 'user1',
          'usergroup' => 'usergroup1'
        }
      },
      @membership2.id => {
        'attributes' => {
          'user'      => 'user2',
          'usergroup' => 'usergroup2'
        }
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_creating_a_membership
    ensure_no_membership_is_present
    ensure_associations_are_present

    post '/memberships', :membership => { :user => 'user1', :usergroup => 'usergroup1' }
    assert last_response.redirection?
    assert_equal 'Membership created', last_response.body
    follow_redirect!

    assert_match %r{http://example.org/memberships/\d+}, last_request.url
    assert last_response.ok?
  end

  def test_creating_a_membership_with_existing_association_should_not_work
    ensure_memberships_are_present

    post '/memberships', :membership => { :user => 'user1', :usergroup => 'usergroup1' }

    expected = [
      "Error while saving membership",
      "this membership already exists",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
    follow_redirect!

    assert_equal 'http://example.org/memberships/new', last_request.url
    assert last_response.ok?
  end

  def test_getting_a_membership
    ensure_memberships_are_present

    get "/memberships/#{@membership1.id}"
    assert last_response.ok?

    expected = {
      @membership1.id => {
        'attributes' => {
          'user'      => 'user1',
          'usergroup' => 'usergroup1'
        }
      }
    }
    assert_equal expected, y(last_response.body)
  end

  def test_getting_an_unexisting_membership_should_not_work
    get '/memberships/not-existing-membership'
    assert last_response.not_found?
    assert_equal "Membership not found", last_response.body
  end

  def test_getting_the_new_membership_infos
    get '/memberships/new'
    assert last_response.ok?

    expected = {
      'membership' => {
        'user'      => 'String',
        'usergroup' => 'String'
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_a_membership_edit_form_should_not_work
    ensure_memberships_are_present

    get "/memberships/edit/#{@membership1.id}"
    assert last_response.not_found?
    assert_equal 'Command not found', last_response.body
  end

  def test_updating_a_membership_should_not_work
    ensure_memberships_are_present

    put "/memberships/#{@membership1.id}", :membership => { :user => 'user2' }
    assert last_response.not_found?
    assert_equal 'Command not found', last_response.body

    post "/memberships/#{@membership1.id}",
      :membership => { :user => 'user2' },
      :_method => 'put'
    assert last_response.not_found?
    assert_equal 'Command not found', last_response.body
  end

  def test_deleting_a_membership
    ensure_memberships_are_present

    delete "/memberships/#{@membership1.id}"
    assert last_response.redirection?
    assert_equal 'Membership removed', last_response.body
  end

  def test_deleting_a_membership_with_post
    ensure_memberships_are_present

    delete "/memberships/#{@membership1.id}"
    assert last_response.redirection?
    assert_equal 'Membership removed', last_response.body
  end

  private

  def ensure_memberships_are_present
    ensure_no_membership_is_present
    ensure_associations_are_present
    @membership1 = Membership.create({ :user => 'user1', :usergroup => 'usergroup1' })
    @membership2 = Membership.create({ :user => 'user2', :usergroup => 'usergroup2' })
  end

  def ensure_no_membership_is_present
    Membership.destroy_all
  end

  def ensure_associations_are_present
    User.find_or_create_by_name('user1')
    User.find_or_create_by_name('user2')
    Usergroup.find_or_create_by_name('usergroup1')
    Usergroup.find_or_create_by_name('usergroup2')
  end
end