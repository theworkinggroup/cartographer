require 'helper'

class TestMap < ActiveSupport::TestCase
  include Cartographer
  include Cartographer::Geometry
  
  test "Check default options" do
    assert Map.defaultOptions, {
      :identifier => 'cartographer',
      :div_id => 'map',
      :controls => :default,
      :zoom => 9
    }
  end
  
  test "Test loading of Javascript libraries" do
    expected = %Q{<script type='text/javascript'>\n$(document).ready(function(){\nCartographer.apikey = 'thisismyfakegoogletestingkey';\nCartographer.apiversion = 2;\nCartographer.loadAPIs();\n});\n</script>}
    assert_equal Map.to_js, expected
  end
  
  test "Initialization of a map" do
    map = Map.new(:center => [40.1, 40.2], :zoom => 8)
    assert_equal map.center, Location.new(:lat => 40.1, :lng => 40.2)
    assert_equal map.zoom, 8
  end
  
  test "Setting center from different kinds of inputs" do
    #Map should be smart enough to figure out what we mean based on the types of input.
    [[40.1, 40.2], {:lat => 40.1, :lng => 40.2}, Location.new(:lat => 40.1, :lng => 40.2), Point.new(:lat => 40.1, :lng => 40.2)].each do |c|
      map = Map.new
      map.center = c
      assert_equal map.center, Location.new(:lat => 40.1, :lng => 40.2)
    end
  end
  
  test 'Test translation to Javascript' do
    expected = %Q{<script type='text/javascript'>\nvar test_id = new Cartographer('map_id');\n$(window).bind('mapsLoaded', function(){\ntest_id.initialize(function(){\ntest_id.map.setCenter(new GLatLng(, ));\ntest_id.map.setZoom(5);\ntest_id.map.setUIToDefault();\n});\n});\n</script>}
    map = Map.new(:center => [40.1, 40.2], :zoom => 5, :identifier => 'test_id', :div_id => 'map_id', :controls => :default)
    assert_equal map.to_js, expected
  end
  
end
