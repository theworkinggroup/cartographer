require 'helper'

class TestMap < ActiveSupport::TestCase
  include Cartographer
  
  test "Check default options" do
    assert Map.default_options, {
      :identifier => 'cartographer',
      :div_id => 'map',
      :controls => :default,
      :zoom => 9
    }
  end
end
