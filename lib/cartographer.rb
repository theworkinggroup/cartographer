module Cartographer
  autoload(:Location, 'cartographer/location')
  autoload(:Map, 'cartographer/map')
  autoload(:SquareCode, 'cartographer/square_code')
  
  VERSION = "0.1"

  class << self
    def log message
      logger.info("[cartographer] #{message}") if logging?
    end

    def logger #:nodoc:
      ActiveRecord::Base.logger
    end

    def logging? #:nodoc:
      options[:log]
    end
  end

  module Exceptions
    class ConfigFileNotFound < StandardError; end
    class InvalidLocation < StandardError; end
  end

end
