class TC_AliasTest < Test::Unit::TestCase
  include AppTestCase

  def test_empty_response_at_beginning
    ensure_no_alias_is_present

    get '/aliases'
    assert last_response.ok?
    assert last_response.body.empty?
  end

  def test_getting_all_aliases
    ensure_aliases_are_present

    get '/aliases'
    assert last_response.ok?

    expected = {
      'alias1' => 'target1',
      'alias2' => 'target1',
      'alias3' => 'target2',
      'alias4' => 'target2'
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_filtered_aliases
    ensure_aliases_are_present

    get '/aliases?target=target1'
    assert last_response.ok?

    expected = {
      'alias1' => 'target1',
      'alias2' => 'target1'
    }

    assert_equal expected, y(last_response.body)
  end

  def test_creating_an_alias
    ensure_targets_are_present

    post '/aliases', :alias => {
      :name        => 'alias-test1',
      :target_name => 'target1'
    }
    assert last_response.redirection?
    assert_equal 'Alias created', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/aliases/alias-test1', last_request.url
    assert last_response.ok?
  end

  def test_creating_an_alias_with_existing_name_should_not_work
    ensure_aliases_are_present

    post '/aliases', :alias => { :name => 'alias1', :target_name => 'target1' }

    expected = [
      "Error while saving alias",
      "name has already been taken",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
    follow_redirect!

    assert_equal 'http://example.org/aliases/new', last_request.url
    assert last_response.ok?
  end

  def test_getting_an_alias
    ensure_aliases_are_present

    get '/aliases/alias1'
    assert last_response.ok?

    expected = {
      'alias1' => 'target1'
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_a_non_existent_alias_should_not_work
    get '/aliases/non-existent-alias'
    assert last_response.not_found?
    assert_equal "Alias not found", last_response.body
  end

  def test_getting_the_new_alias_infos
    get '/aliases/new'
    assert last_response.ok?

    expected = {
      'alias' => {
        'name'        => 'String',
        'target_name' => 'String'
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_deleting_a_target
    ensure_aliases_are_present

    delete '/aliases/alias1'
    assert last_response.redirection?
    assert_equal 'Alias removed', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/aliases', last_request.url
    assert last_response.ok?

    get '/aliases/alias1'
    assert last_response.not_found?
  end

  def test_deleting_a_target_with_post
    ensure_aliases_are_present

    post '/aliases/alias1', :_method => 'delete'
    assert last_response.redirection?
    assert_equal 'Alias removed', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/aliases', last_request.url
    assert last_response.ok?

    get '/aliases/alias1'
    assert last_response.not_found?
  end

  private

  def ensure_aliases_are_present
    ensure_no_alias_is_present
    ensure_targets_are_present

    Alias.new(:name => 'alias1', :target_name => 'target1').save
    Alias.new(:name => 'alias2', :target_name => 'target1').save
    Alias.new(:name => 'alias3', :target_name => 'target2').save
    Alias.new(:name => 'alias4', :target_name => 'target2').save
  end

  def ensure_targets_are_present
    Target.destroy_all
    Target.new(:name => 'target1').save
    Target.new(:name => 'target2').save
  end

  def ensure_no_alias_is_present
    Alias.destroy_all
  end
end
