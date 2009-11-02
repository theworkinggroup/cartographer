module Cartographer
  # The Map class represents a Google Map that is to be displayed in a view.
  class Map
    
    #require 'cartographer/geometry/point'
    include Cartographer::Geometry
    
    API_VERSION = 2
    
    attr_accessor :identifier, :div_id, :controls, :center, :zoom
    
    def self.defaultOptions
      @default_options ||= {
        :identifier => 'cartographer',
        :div_id => 'map',
        :controls => :default,
        :center => [43.657154, -79.425124], # Toronto, the center of the Universe
        :zoom => 9
      }
    end
    
    def self.to_js
      output = [ ]
      output << "$(document).ready(function(){"
        output << "Cartographer.apikey = '#{Cartographer.apiKey(:google)}';"
        output << "Cartographer.apiversion = #{API_VERSION};"
        output << "Cartographer.loadAPIs();"
      output << "});"
      "<script type='text/javascript'>\n" + output.join("\n") + "\n</script>"
    end
    
    def initialize(options = {})
      options = self.class.defaultOptions.merge(options)
      
      self.identifier = options[:identifier]
      self.div_id = options[:div_id]
      self.controls = options[:controls]
      self.center = options[:center]
      self.zoom = options[:zoom]
    end
    
    def center=(location)
      case location
      when Location
        @center = location
      when Array
        @center = Location.new(:lat => location[0], :lng => location[1])
      when Hash
        @center = Location.new(:lat => location[:lat], :lng => location[:lng])
      when Point
        @center = Location.new(:lat => location.lat, :lng => location.lng)
      else 
        raise Exceptions::InvalidLocation.new("The location could not be determined from: #{location.inspect}")
      end
    end
    
    def to_js
      output = [ ]
      output << "var #{@identifier} = new Cartographer('#{@div_id}');"
      output << "$(window).bind('mapsLoaded', function(){"
        output << "#{@identifier}.initialize(function(){"
          output << "#{@identifier}.map.setCenter(#{@center.to_js});"
          output << "#{@identifier}.map.setZoom(#{@zoom});"
          output << "#{@identifier}.map.setUIToDefault();" #enhance this so that you can change control types.
        output << "});"
      output << "});"
      "<script type='text/javascript'>\n" + output.join("\n") + "\n</script>"
    end
  end
  
end