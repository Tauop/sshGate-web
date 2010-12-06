class TC_ApplicationTest < Test::Unit::TestCase
  include AppTestCase

  def test_calling_an_undefined_url
    get '/not-existing-url'
    assert last_response.not_found?
    assert_equal 'Command not found', last_response.body
  end
end
