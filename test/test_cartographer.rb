require 'helper'

class TestCartographer < ActiveSupport::TestCase
  include Cartographer
  test "Fetching API keys" do
    assert_equal Cartographer.apiKey(:google), 'thisismyfakegoogletestingkey'
    assert_equal Cartographer.apiKey(:yahoo), 'thisismyfakeyahootestingkey'
  end
end
