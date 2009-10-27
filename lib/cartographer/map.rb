# encoding: utf-8
module Cartographer
  # The Map class represents a Google Map that is to be displayed in a view.
  class Map
    
    API_VERSION = 2
    
    def self.defaultOptions
      @default_options ||= {
        :identifier => 'cartographer',
        :div_id => 'map',
        :controls => :default,
        :zoom => 9
      }
    end
    
    def self.apiKey(env = RAILS_ENV)
      unless File.exist?(RAILS_ROOT + '/config/cartographer.yml')
        raise Exceptions::ConfigFileNotFound.new("File RAILS_ROOT/config/cartographer.yml not found") 
      end
      key = YAML.load_file(RAILS_ROOT + '/config/cartographer.yml')[env]
      #log "Got API key: #{key}"
      key
    end
    
    def self.to_js
      output = [ ]
      output << "$(document).ready(function(){"
        output << "Cartographer.apikey = '#{self.apiKey}';"
        output << "Cartographer.apiversion = #{API_VERSION};"
        output << "Cartographer.loadAPIs();"
      output << "});"
      "<script type='text/javascript'>\n" + output.join("\n") + "\n</script>"
    end
    
    def initialize(options = {})
      options = self.class.defaultOptions.merge(options)
      
      @identifier = options[:identifier]
      @div_id = options[:div_id]
      @controls = options[:controls]
      @center = options[:center]
      @zoom = options[:zoom]
    end
    
    def center=(location)
      case location
      when Location
        @center = location
      when Array
        @center = Location.new(location[0], location[1])
      when Hash
        @center = Location.new(location[:lat], location[:lng])
      else 
        raise Exceptions::InvalidLocation.new("The location could not be determined from: #{location.inspect}")
      end
      #log "Center set to: #{@center}"
    end
    
    def to_js
      output = [ ]
      output << "var #{@identifier} = new Cartographer('#{@div_id}');"
      output << "$(window).bind('mapsLoaded', function(){"
        output << "#{@identifier}.initialize(function(){"
          output << "#{@identifier}.map.setCenter(#{@center.to_js});"
          output << "#{@identifier}.map.setZoom(#{@zoom});"
          output << "#{@identifier}.map.setUIToDefault();" #fix this so that you can change control types.
        output << "});"
      output << "});"
      "<script type='text/javascript'>\n" + output.join("\n") + "\n</script>"
    end
  end
  
end