module Cartographer
  module Geocoders
    class Google 
      
      require 'net/http'
      require 'cgi'
      require 'rubygems'
      require 'active_support'
      
      require 'cartographer/geometry/box'
      
      GEOCODING_HOST = 'maps.google.com'
      GEOCODING_PATH = '/maps/geo'
      
      ACCURACIES = {
          0 => :unknown,
          1 => :country,
          2 => :region,
          3 => :subregion,
          4 => :town,
          5 => :postalcode,
          6 => :street,
          7 => :intersection,
          8 => :address,
          9 => :premise
        }
      
      def locate(address, options = { })
        output = options[:output] || 'json'
        oe = options[:encoding] || 'utf8'
        ll = options[:center]
        unless options[:distance].blank? && options[:center].blank?
          spn = m_to_d(options[:distance])
        end
        gl = options[:cc]
  
        get_parameters = {
          :q => address,
          :key => Cartographer.apiKey(:google),
          :sensor => 'false',
          :output => output,
          :oe => oe,
          :ll => ll,
          :spn => spn,
          :gl => gl
        }.reject!{|k,v| v == nil}
        
        response = Net::HTTP.get(GEOCODING_HOST, GEOCODING_PATH + '?' + get_parameters.collect{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&') )
        response = ActiveSupport::JSON.decode(response)
        
        if response["Status"]["code"] == 200
          locations = response["Placemark"].collect do |p|
            Location.new do |l|
              l.full_address = Cartographer.dig_hash(p, %w[address])
              l.street_address = Cartographer.dig_hash(p, %w[AddressDetails Country AdministrativeArea SubAdministrativeArea Locality Thoroughfare ThoroughfareName])
              l.state = Cartographer.dig_hash(p, %w[AddressDetails Country AdministrativeArea AdministrativeAreaName])
              l.country = Cartographer.dig_hash(p, %w[AddressDetails Country CountryName])
              l.accuracy = ACCURACIES[Cartographer.dig_hash(p, %w[AddressDetails Accuracy])] if Cartographer.dig_hash(p, %w[AddressDetails Accuracy])
              l.lat = Cartographer.dig_hash(p, %w[Point coordinates])[0]
              l.lng = Cartographer.dig_hash(p, %w[Point coordinates])[1]
              box = Box.new(:south => Cartographer.dig_hash(p, %w[ExtendedData LatLonBox south]),
                            :north => Cartographer.dig_hash(p, %w[ExtendedData LatLonBox north]),
                            :east => Cartographer.dig_hash(p, %w[ExtendedData LatLonBox east]),
                            :west => Cartographer.dig_hash(p, %w[ExtendedData LatLonBox west]) )
              l.box = box
            end
          end
        end
      end
    end
    
  end
end