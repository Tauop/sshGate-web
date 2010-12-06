class TC_TargetTest < Test::Unit::TestCase
  include AppTestCase

  def test_empty_response_at_beginning
    ensure_no_target_is_present

    get '/targets'
    assert last_response.ok?
    assert last_response.body.empty?
  end

  def test_getting_all_targets
    ensure_targets_are_present

    get '/targets'
    assert last_response.ok?

    expected = {
      'target1' => {
        'attributes' => {
          'public_key'     => public_key,
          'ssh_port'       => 22,
          'scp_port'       => 22,
          'ssh_enable_x11' => false
        }
      },
      'target2' => {
        'attributes' => {
          'public_key'     => '',
          'ssh_port'       => 42,
          'scp_port'       => 4242,
          'ssh_enable_x11' => true
        }
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_creating_a_target
    post '/targets', :target => { :name => 'target-test1' }
    assert last_response.redirection?
    assert_equal 'Target created', last_response.body
    follow_redirect!

    assert_equal 'http://example.org/targets/target-test1', last_request.url
    assert last_response.ok?
  end

  def test_creating_a_target_with_existing_name_should_not_work
    ensure_targets_are_present

    post '/targets', :target => { :name => 'target1' }

    expected = [
      "Error while saving target",
      "name has already been taken",
      ""
    ].join("\n")

    assert_equal expected, last_response.body
    follow_redirect!

    assert_equal 'http://example.org/targets/new', last_request.url
    assert last_response.ok?
  end

  def test_getting_a_target
    ensure_targets_are_present

    get '/targets/target1'
    assert last_response.ok?

    expected = {
      'target1' => {
        'attributes' => {
          'public_key'     => public_key,
          'ssh_port'       => 22,
          'scp_port'       => 22,
          'ssh_enable_x11' => false
        }
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_an_unexisting_target_should_not_work
    get '/targets/not-existing-target'
    assert last_response.not_found?
    assert_equal "Target not found", last_response.body
  end

  def test_getting_the_new_target_infos
    get '/targets/new'
    assert last_response.ok?

    expected = {
      'target' => {
        'name'           => 'String',
        'private_key'    => 'Text',
        'ssh_port'       => 'Integer',
        'scp_port'       => 'Integer',
        'ssh_enable_x11' => 'Boolean'
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_getting_an_target_edit_form
    ensure_targets_are_present

    get '/targets/edit/target1'
    assert last_response.ok?

    expected = {
      'target' => {
        'name'           => 'String',
        'private_key'    => 'Text',
        'ssh_port'       => 'Integer',
        'scp_port'       => 'Integer',
        'ssh_enable_x11' => 'Boolean'
      },
      'data' => {
        'name'           => 'target1',
        'public_key'     => public_key,
        'ssh_port'       => 22,
        'scp_port'       => 22,
        'ssh_enable_x11' => false
      }
    }

    assert_equal expected, y(last_response.body)
  end

  def test_updating_a_target_with_put
    ensure_targets_are_present

    put '/targets/target1', :target => {
      :name => 'target42'
    }
    assert last_response.redirection?
    assert_equal 'Target updated', last_response.body
    follow_redirect!

    assert last_response.ok?
    assert_equal 'http://example.org/targets/target42', last_request.url
  end

  def test_updating_a_target_with_post
    ensure_targets_are_present

    post '/targets/target1', :target => {
      :name => 'target42'
    }, :_method => 'put'
    assert last_response.redirection?
    assert_equal 'Target updated', last_response.body
    follow_redirect!

    assert last_response.ok?
    assert_equal 'http://example.org/targets/target42', last_request.url
  end

  def test_deleting_a_target
    ensure_targets_are_present

    delete '/targets/target1'
    assert last_response.redirection?
    assert_equal 'Target removed', last_response.body
  end

  def test_deleting_a_target_with_post
    ensure_targets_are_present

    post '/targets/target1', :_method => 'delete'
    assert last_response.redirection?
    assert_equal 'Target removed', last_response.body
  end

  private

  def ensure_targets_are_present
    ensure_no_target_is_present

    Target.create({
      :name        => 'target1',
      :private_key => private_key
    })
    Target.create({
      :name           => 'target2',
      :ssh_port       => 42,
      :scp_port       => 4242,
      :ssh_enable_x11 => true
    })
  end

  def ensure_no_target_is_present
    Target.destroy_all
  end

  def private_key
    "-----BEGIN RSA PRIVATE KEY-----\n"                                  \
    "MIIEpAIBAAKCAQEA0P9XjtSMxwm9Dlq6Jn3gNdc59q+775FEFSYlkBGki2oJ9bPW\n" \
    "LHQvub5wScT40uI34e35mbGyWMxt+jq4XQEnz8KoYro31icg6EqkAlMBfrBXzWnC\n" \
    "q2nmQVutMhc04d7/DjzJButqhFK6PtpcQu88ru/3lfXU680E9ChgB32mRLzCWuzc\n" \
    "AletxFn3gl4mbN1GZjQZqECWBO+QAdkOLRT5IG+rVoo0kDeVTEpTbCzjaQiWcR8h\n" \
    "Wwwm418UZf02O7mKZA6n0bTKMqQNUdwb8vKaYNeEHpZGSeum6ib0wUfRNOZgMfdU\n" \
    "z6aNjWNObhqy2AGC2iGMikj9NI/pZ+hbqSrFVwIBIwKCAQEAywas0+Rrf4XNmOpr\n" \
    "sF0FsKUw/kRQKo0dkOM6brINjr7H2L1Ttie5VVnpbDuv4s0gV9E7nJ39tVjf3SMZ\n" \
    "fust/QY9LLTlyLhL2lci+vGMbHDKUoP+76izynZQec1mkkZW2qFy04WarG2e+zqF\n" \
    "gtnF68SKHKWqRCY/U5Tvkj+LkzlCPCmLQLcLSnRdC5KDhTdRzOrwt13ttn2dfbvS\n" \
    "y6VD5uOMQyB2EHJVIGKAzvZajqVaqns+cdbK5lnEBDYndClvtbmkuleCtVLOk3EZ\n" \
    "QY2st3+N98/T85ZnrOf2LnBJE7pZV94CBDP/MiQDye8KJoUoPtFK6xA9lZhJg0qu\n" \
    "43cZuwKBgQD//XXdZlNPenMoHYz5IvOScx/B6Z3UJjkGKksojGUAiCTexTQscTFF\n" \
    "zcZd/nbE+eNe4h2GUnIAHrfdrD0e2AFTFmmzcEHUOrruzBJPn71jnFnfE8eZn5Z+\n" \
    "DxcvSuzonr3JBG729SC1R1JyeKhfcEqOqH38xHI4adByPl5QModCGwKBgQDRAWpY\n" \
    "rDjhuX4VQlDxMbhJJ6oFmHbFotrgMHm5zw1f31F/8eHK0dvozh6O8wPQRbc8G774\n" \
    "3rWDE8NHTADQqGBibO1hZWQrpqp3DCCqy/YyJbaS5g9Set/6XcaiZKsV1KyGgEHy\n" \
    "Xbm6+9y58N4jTx7SS1OkiJFYOEhYqepXbl2ddQKBgQCoONhs63iTUHePY+BL8mWM\n" \
    "H8RpfEMlAyzJiYHY0Umv5HAAGzDqAT2i5k8n0xrZNn943buhaWDbgeaKWz4blUKy\n" \
    "8XipHeIdwDGy3eAlsh1etzO+erZdo2LlH9wJIpuuzrc69EjrbeJLPX9Sic27D0bw\n" \
    "CFLKrPqaGaY8ciC4W7f4PQKBgQC/Fzyo1/l962v2LgDchTrGiqoTvph6Ln74290B\n" \
    "p1yvbRdQaB7lUiglTrzad8j470hxeHQWvP25q6s53xawJOponhrctHjXc88NwfH7\n" \
    "PiLsBTk12aeb3g6bw3PHrH8p5wQjM29+gZPeKBpDmmSykXtD7RlF+TRt6lDGF7Gv\n" \
    "BdHvCwKBgQDPpowwei4mkzEPdMAKc5j49xHffJQUn3fZMMDTIryoRo2rmWTqVLuP\n" \
    "pIE4ZjndyzLOw5HbIYdSNypu+/Hpo3yYYFwAyjuRCRVZwCh9uv3hxyf6ft61pvnA\n" \
    "52UteVS6ff4/PfcOA7x9+m0Rw+rVDvi4oCoC3+ANYMHnphYvDsujJg==\n"         \
    "-----END RSA PRIVATE KEY-----\n"
  end

  def public_key
    'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0P9XjtSMxwm9Dlq6Jn3gNdc59q+7' \
    '75FEFSYlkBGki2oJ9bPWLHQvub5wScT40uI34e35mbGyWMxt+jq4XQEnz8KoYro3' \
    '1icg6EqkAlMBfrBXzWnCq2nmQVutMhc04d7/DjzJButqhFK6PtpcQu88ru/3lfXU' \
    '680E9ChgB32mRLzCWuzcAletxFn3gl4mbN1GZjQZqECWBO+QAdkOLRT5IG+rVoo0' \
    'kDeVTEpTbCzjaQiWcR8hWwwm418UZf02O7mKZA6n0bTKMqQNUdwb8vKaYNeEHpZG' \
    'Seum6ib0wUfRNOZgMfdUz6aNjWNObhqy2AGC2iGMikj9NI/pZ+hbqSrFVw== '
  end
end
