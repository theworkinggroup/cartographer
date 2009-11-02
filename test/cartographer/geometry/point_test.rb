require 'helper'

class TestPoint < ActiveSupport::TestCase
  include Cartographer
  
  test "Check point creation and output" do
    point = Cartographer::Geometry::Point.new(:lat => 47.4728743, :lng => -120.3387102)
    assert_equal point.to_js, "new GLatLng(47.4728743, -120.3387102)"
  end
end