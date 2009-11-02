module Cartographer
  class Geocoder
    
    require 'cartographer/geocoders/google'
    require 'cartographer/geocoders/yahoo'
    
    def self.new(geocoder = nil)
      case geocoder
      when :google
        return Geocoders::Google.new
      when :yahoo
        return Geocoders::Yahoo.new
      when nil
        return Geocoders::Google.new if Cartographer.config.default_provider == :google
        return Geocoders::Yahoo.new if Cartographer.config.default_provider == :yahoo
      end
    end
    
  end
end