
# http://apidock.com/ruby/OpenStruct

require 'ostruct'

class Cartographer
  class Config < OpenStruct
  end
end

class Cartographer
  def self.config(reload = false)
    @config = nil if (reload)
    @config ||= Cartographer::Config.new
  end
end

Cartographer::Config.assign do |config|
  config.provider = :google
end

Cartographer.config.provider = :google

location =
  Cartographer.locate do |locator|
    locator.address = '123 Main St'
    locator.city = 'Toronto'
  end

location = Cartographer.locate(:address => '123 Main St.', :city => 'Toronto')

begin
  location = Cartographer.locate!(:address => '123 Main St.', :city => 'Toronto')
rescue Cartographer::LocationNotFound
  # ...
end

location = Cartographer.locate(:address => '123 Main St.', :origin => home_location)

locations = Cartographer.locate_all(:address => '123 Main St.', :country => 'CA')
