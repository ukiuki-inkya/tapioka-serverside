# frozen_string_literal: true

require 'test_helper'

class TapisControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get tapis_create_url
    assert_response :success
  end
end
