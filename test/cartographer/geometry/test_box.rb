require 'helper'

class TestBox < ActiveSupport::TestCase
  include Cartographer
  
  test "Check box creation and output" do
    box = Cartographer::Geometry::Box.new(:south => 47.4665791, :north => 47.4728743, :east => -120.332415, :west => -120.3387102)
    assert_equal box.to_js, "new GPolygon([new GLatLng(47.4728743, -120.3387102), new GLatLng(47.4728743, -120.332415), new GLatLng(47.4665791, -120.332415), new GLatLng(47.4665791, -120.3387102)])"
    assert_equal box.polygon, box.to_js
    assert_equal box.bounds, "new GLatLngBounds(new GLatLng(47.4665791, -120.3387102), new GLatLng(47.4728743, -120.332415))"
  end
end