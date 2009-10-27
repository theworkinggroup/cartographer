# encoding: utf-8
module Cartographer
  # The Location class represents a point on the Earth.
  class Location
    require 'net/http'
    
    # From Wikipedia:
      # The nautical mile is a unit of length corresponding approximately to one minute of arc of latitude along any meridian.
      
    # Useful conversions:
    # 1 Arc Minute = 1 Nautical Mile
    # 1 Nautical Mile = 1.15078 Miles
    # 1 Nautical Mile = 6076.12 Feet
    # 1 Nautical Mile = 1852.00 Metres
    # 1 Arc Second = 30.866... Metres
    
    # The radius of the Earth only varies by 0.3% from Equator to Pole, so we can treat it as a sphere for these purposes.
    # The Vincenty distance formula is included for when this discrepancy is not acceptable.
    # Earth Equatorial Radius: 6 378 137 Metres
    # Earth Polar Radius: 6 356 752.3 Metres
    # Based on these, average radius: 6 367 444.5 Metres
    EARTH_RADIUS = 6367444.5
    EARTH_CIRCUMFERENCE = 2 * Math::PI * EARTH_RADIUS
    
    DEGREE_TO_RADIAN = 0.0174532925199433
    
    M_IN_KM = 1000
    M_IN_MI = 1609.344
    
    GEOCODING_HOST = 'maps.google.com'
    GEOCODING_PATH = '/maps/geo'
    
    def self.geolocate(address, options = { })
      output = options[:output] || 'json'
      oe = options[:encoding] || 'utf8'
      ll = options[:center]
      unless options[:distance].blank? && options[:center].blank?
        spn = m_to_d(options[:distance])
      end
      gl = options[:cc]
      
      get_parameters = {
        :q => address,
        :key => Map.apiKey,
        :sensor => false,
        :output => output,
        :oe => oe,
        :ll => ll,
        :spn => spn,
        :gl => gl
      }.reject!{|k,v| v == nil}
      
      response = Net::HTTP.get(GEOCODING_HOST, GEOCODING_PATH + '?' + get_parameters.collect{|k,v| "#{k}=#{Rack::Utils.escape(v)}"}.join('&') )
      raise ActiveSupport::JSON.decode(response)
      
    end
    
    def self.new_from_response
      
    end
    
    def self.dms_to_decimal(d, m, s)
      d + m/60.0 + s/3600.0
    end
    
    def initialize(options = {})
      @latitude = options[:lat]
      @longitude = options[:lng]
    end
    
    def lat
      @latitude
    end
    
    def lng
      @longitude
    end
    
    def distance_to(location, options = {})
      d = haversine_distance(location)
      return d/M_IN_KM if options[:in] == :kms
      return d/M_IN_MI if options[:in] == :miles
      return d
    end
    
    def to_js
      "new GLatLng(#{@latitude}, #{@longitude})"
    end
    
    protected
    
    # metres to degrees on a sphere with the earth's radius.
    def m_to_d(m)
      (360.0*m)/EARTH_CIRCUMFERENCE
    end
    
    # degrees to metres on a sphere with the earth's radius.
    def d_to_m(d)
      (EARTH_CIRCUMFERENCE/360)*d
    end
    
    # Adapted from GeoRuby. I lifted this because I didn't think 
    # it warranted adding a gem dependency to Cartographer. Thanks GeoRuby!
    # Returns distance in metres.
    def haversine_distance(point)
      radlat_from = lat * DEGREE_TO_RADIAN
      radlat_to = point.lat * DEGREE_TO_RADIAN

      dlat = (point.lat - lat) * DEGREE_TO_RADIAN
      dlon = (point.lng - lng) * DEGREE_TO_RADIAN

      a = Math.sin(dlat/2)**2 + Math.cos(radlat_from) * Math.cos(radlat_to) * Math.sin(dlon/2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      EARTH_RADIUS * c
    end
    
    # Adapted from GeoRuby.
    # Returns distance in metres.
    def vincenty_distance(point, a = 6378137.0, b = 6356752.3142)
      f = (a-b) / a
      l = (point.lng - lng) * DEGREE_TO_RADIAN

      u1 = Math.atan((1-f) * Math.tan(lat * DEGREE_TO_RADIAN ))
      u2 = Math.atan((1-f) * Math.tan(point.lat * DEGREE_TO_RADIAN))
      sinU1 = Math.sin(u1)
      cosU1 = Math.cos(u1)
      sinU2 = Math.sin(u2)
      cosU2 = Math.cos(u2)

      lambda = l
      lambdaP = 2 * Math::PI
      iterLimit = 20

      while (lambda-lambdaP).abs > 1e-12 && --iterLimit>0
        sinLambda = Math.sin(lambda)
        cosLambda = Math.cos(lambda)
        sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda))

        return 0 if sinSigma == 0 #coincident points

        cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda
        sigma = Math.atan2(sinSigma, cosSigma)
        sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
        cosSqAlpha = 1 - sinAlpha*sinAlpha
        cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha

        cos2SigmaM = 0 if (cos2SigmaM.nan?) #equatorial line: cosSqAlpha=0

        c = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha))
        lambdaP = lambda
        lambda = l + (1-c) * f * sinAlpha * (sigma + c * sinSigma * (cos2SigmaM + c * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)))
      end
      return NaN if iterLimit==0 #formula failed to converge

      uSq = cosSqAlpha * (a*a - b*b) / (b*b)
      a_bis = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)))
      b_bis = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)))
      deltaSigma = b_bis * sinSigma*(cos2SigmaM + b_bis/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)- b_bis/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)))

      b*a_bis*(sigma-deltaSigma)
    end
  end
end