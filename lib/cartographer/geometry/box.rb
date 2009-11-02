module Cartographer
  module Geometry
    class Box
      
      require 'cartographer/geometry/point'
      
      attr_accessor :south, :north, :east, :west
      
      def initialize(options = {}, &block)
        if block_given?
          yield self
        else
          @south = options[:south]
          @north = options[:north]
          @east = options[:east]
          @west = options[:west]
        end
      end
      
      # These all assume Google
      def polygon
        to_js
      end
      
      def bounds
        "new GLatLngBounds(#{sw.to_js}, #{ne.to_js})"
      end
      
      def to_js
        "new GPolygon([#{nw.to_js}, #{ne.to_js}, #{se.to_js}, #{sw.to_js}])"
      end
      
      def method_missing(method, *args, &block)
        case method
        when :nw
          Point.new(:lat => @north, :lng => @west)
        when :ne
          Point.new(:lat => @north, :lng => @east)
        when :se
          Point.new(:lat => @south, :lng => @east)
        when :sw
          Point.new(:lat => @south, :lng =>  @west)
        else
          raise NoMethodError
        end
      end
      
    end
  end
end