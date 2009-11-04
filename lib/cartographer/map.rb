module Cartographer
  # The Map class represents a Google Map that is to be displayed in a view.
  class Map
    
    #require 'cartographer/geometry/point'
    include Cartographer::Geometry
    
    API_VERSION = 2
    
    attr_accessor :identifier, :div_id, :controls, :center, :zoom, :events
    
    def self.defaultOptions
      @default_options ||= {
        :identifier => 'cartographer',
        :div_id => 'map',
        :controls => :default,
        :center => [43.657154, -79.425124], # Toronto, the center of the Universe
        :zoom => 9,
        :events => { }
      }
    end
    
    def self.to_js
      output = [
      "$(document).ready(function(){",
        "Cartographer.apikey = '#{Cartographer.apiKey(:google)}';",
        "Cartographer.apiversion = #{API_VERSION};",
        "Cartographer.loadAPIs();",
      "});" ]
      
      "<script src='/javascripts/cartographer/cartographer.js' type='text/javascript'></script><script type='text/javascript'>\n" + output.join("\n") + "\n</script>"
    end
    
    def initialize(options = {})
      options = self.class.defaultOptions.dup.merge(options)
      
      @identifier = options[:identifier]
      @div_id = options[:div_id]
      @controls = options[:controls]
      @center = options[:center]
      @zoom = options[:zoom]
      @events = { }
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
      when String
        @center = location #to support putting in a Javascript function.
      else 
        raise Exceptions::InvalidLocation.new("The location could not be determined from: #{location.inspect}")
      end
    end
    
    def register_event(event, function)
      @events[event] = [] if @events[event].blank?
      @events[event] << function
    end
    
    def to_js
      load_events = @events[:load].collect{|function| "GEvent.addListener(#{@identifier}.map, 'load', #{function.to_s});" }
      other_events = @events.collect do |event|
        if event[0] != :load
          event[1].collect do |function|
            "GEvent.addListener(#{@identifier}.map, '#{event[0]}', #{function.to_s});"
          end
        end
      end
      output = [
      "var #{@identifier} = new Cartographer('#{@div_id}');",
      "$(window).bind('mapsLoaded', function(){",
        "#{@identifier}.initialize(function(){",
          load_events,
          "#{@identifier}.map.setCenter(#{@center.is_a?(String) ? @center : @center.to_js}, #{@zoom});",
          "#{@identifier}.map.setUIToDefault();", #enhance this so that you can change control types.
          other_events,
        "});",
      "});" ]
      "<script type='text/javascript'>\n" + output.flatten.join("\n") + "\n</script>"
    end
  end
  
end