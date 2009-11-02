require 'helper'

class TestGeocoder < ActiveSupport::TestCase
  include Cartographer
  
  test "Returns the requested geocoding class correctly" do
    assert_kind_of Cartographer::Geocoders::Google, Geocoder.new(:google)
    assert_kind_of Cartographer::Geocoders::Yahoo, Geocoder.new(:yahoo)
  end
end