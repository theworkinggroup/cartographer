module Cartographer
  module Geometry
    class Point
      attr_accessor :lat, :lng
      
      def initialize(options = {}, &block)
        if block_given?
          yield self
        else
          @lat = options[:lat]
          @lng = options[:lng]
        end
      end
      
      def to_js
        "new GLatLng(#{@lat}, #{@lng})"
      end
      
    end
  end
end