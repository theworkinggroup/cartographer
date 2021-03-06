require 'cartographer/geocoder'
require 'cartographer/location'
require 'cartographer/map'
require 'cartographer/square_code'

include Cartographer

module Cartographer
   
  def self.log message
    logger.info("[cartographer] #{message}") if logging?
  end
  
  def self.logger #:nodoc:
    ActiveRecord::Base.logger
  end
  
  def self.logging? #:nodoc:
    rails_env == 'development'
  end
  
  def self.apiKey(provider = Cartographer.config.default_provider, env = Cartographer.rails_env)
    if Cartographer.config.api_keys[provider.to_sym][env.to_sym].blank?
      raise Exceptions::APIKeyNotFound.new("Requested API key not found!") 
    end
    key = Cartographer.config.api_keys[provider.to_sym][env.to_sym]
  end
  
  #for gem testing when there is no Rails around.
  def self.rails_env
    defined?(Rails) ? Rails.env : 'test'
  end
  
  def self.rails_root
    defined?(Rails) ? Rails.root : File.expand_path(File.join('..', 'generators', 'cartographer', 'templates'), File.dirname(__FILE__))
  end
  
  def self.dig_hash(hash, *path)
    path.flatten.inject(hash) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
  
  def self.config(&block)
    if block_given?
      yield Cartographer::Config
    else
      return Cartographer::Config
    end
  end
  
  class Config
    require 'active_support'
    def self.cattr_accessor_with_default(name, value = nil)
      cattr_accessor name
      self.send("#{name}=", value) if value
    end
    
    cattr_accessor_with_default :default_provider, :google
    cattr_accessor_with_default :api_keys
    cattr_accessor_with_default :country_bias, 'CA'
    if Cartographer.rails_env == 'test'
      require File.join(Cartographer.rails_root, 'config', 'initializers', 'cartographer.rb')
    end
  end
  
  class Exceptions
    class APIKeyNotFound < StandardError; end
    class InvalidLocation < StandardError; end
  end

end
