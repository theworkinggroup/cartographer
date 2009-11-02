module Cartographer
  class SquareCode
    class InvalidArguments < Exception
    end

    class InvalidEncoding < Exception
    end
    
    class OutOFBounds < Exception
    end
    
    # == Constants ============================================================
  
    MAXIMUM_RESOLUTION = 31
    
    ACCEPTABLE_ENCODING_RANGE = (0..1 << MAXIMUM_RESOLUTION)
  
    LOG2 = Math.log(2)
    LAT_BASE_SCALE = (1 << MAXIMUM_RESOLUTION).to_f / 180
    LONG_BASE_SCALE = -1 * (1 << MAXIMUM_RESOLUTION).to_f / 360
    
    BITMASKS = (0..MAXIMUM_RESOLUTION).collect do |i|
      1 << i
    end.freeze

    OFFSET_BITMASK = [
      0xAAAAAAAAAAAAAAAA,
      0x5555555555555555
    ].freeze

    # == Properties ===========================================================

    attr_accessor :latitude, :longitude
    attr_accessor :square_x, :square_y

    # == Class Methods ========================================================
  
    def self.merge(a, b, zoom = MAXIMUM_RESOLUTION * 2)
      # Engage the MSB in the result to ensure no conflict with regions
      # at a lower precision.
      result = (1 << zoom)

      # Interleave lat and long on a bit-by-bit basis
      BITMASKS[0, (zoom / 2)].each_with_index do |m, o|
        result |= (a & m) << (o + 1)
        result |= (b & m) << o
      end

      result
    end
  
    def self.encoding_size(value)
      bit_length = value.to_s(2).length
      
      # In format Bxy[xy[..]] there must be an odd number of bits to be
      # a valid encoding.

      unless ((bit_length % 2) == 1)
        raise InvalidEncoding, "SquareCode is of length #{bit_length} and cannot be decoded"
      end
      
      bit_length / 2
    end
  
    def self.split(value, zoom = MAXIMUM_RESOLUTION * 2)
      base = encoding_size(value)
    
      lat = 0
      long = 0
    
      offset = ((zoom / 2) - base)

      # Bxyxyxyxyxy => value
      #  Bxyxyxyxyx => ovalue
    
      ovalue = (value >> 1)
    
      base.times do |o|
        pmask = (1 << (o * 2))
      
        lat |= (ovalue & pmask) >> o
        long |= (value & pmask) >> o
      end

      [ lat << offset, long << offset ]
    end

    def self.encode(lat, long, level = nil)
      enc_lat = ((lat.to_f + 90.0) * LAT_BASE_SCALE).to_i
      enc_long = ((long.to_f - 180.0) * LONG_BASE_SCALE).to_i
      
      unless (ACCEPTABLE_ENCODING_RANGE.include?(enc_lat))
        raise OutOFBounds, "Latitude %.6f is not in the range -90.0 to 90.0" % lat
      end

      unless (ACCEPTABLE_ENCODING_RANGE.include?(enc_long))
        raise OutOFBounds, "Longitude %.6f is not in the range -180.0 to 180.0" % long
      end

      level ||= MAXIMUM_RESOLUTION

      result = merge(enc_lat, enc_long)

      # Reduce precision according to level parameter
      if (level and level > 0)
        result >>= ((MAXIMUM_RESOLUTION - level) * 2)
      end

      result
    end

    def self.decode(square)
      (lat, long) = split(square)

      [
        lat.to_f / LAT_BASE_SCALE - 90.0,
        long.to_f / LONG_BASE_SCALE + 180.0
      ]
    end
  
    def self.range(square)
      [
        decode(square),
        decode(increment(increment(square), 1))
      ]
    end
  
    def self.around_square(square)
      [
        Location.offset(square, -1, -1),
        Location.offset(square, 0, -1),
        Location.offset(square, 1, -1),

        Location.offset(square, -1, 0),
        square,
        Location.offset(square, 1, 0),

        Location.offset(square, -1, 1),
        Location.offset(square, 0, 1),
        Location.offset(square, 1, 1)
      ]
    end
  
    def self.zoom_level_for_degrees(degrees, range)
      (Math.log(range / degrees) / LOG2).ceil
    rescue FloatDomainError
      16
    end
  
    def self.zoom_for_viewport(ne, sw)
      lat_degrees = (ne[0] - sw[0]).to_f
      long_degrees = (ne[1] - sw[1]).to_f
    
      level =
        if (lat_degrees > long_degrees * 2)
          zoom_level_for_degrees(lat_degrees, 180)
        else
          zoom_level_for_degrees(long_degrees, 360)
        end
       level < 3 ? 3 : level

    end
  
    def self.increment(value, offset = 0, increment = 1)
      mask = OFFSET_BITMASK[offset]

      ((value | mask) + increment) & ~mask | (value & mask)
    end
  
    def self.offset(code, lat_diff, long_diff)
      zoom = encoding_size(code)
    
      (lat, long) = split(code, zoom * 2)
    
      merge(lat + lat_diff, long + long_diff, zoom * 2)
    end

    def self.squares_for_viewport(ne, sw, zoom = nil)
      zoom ||= zoom_for_viewport(ne, sw)
    
      [
        encode(ne[0], ne[1], zoom),
        encode(sw[0], sw[1], zoom),
        encode(ne[0], sw[1], zoom),
        encode(sw[0], ne[1], zoom)
      ].uniq
    end
  
    # == Instance Methods =====================================================
  
    def initialize(*args)
      case (args.length)
      when 1
        @encoded = args.first.to_i
        
        (@latitude, @longitude) = self.class.decode(@encoded)
      when 2
        (@latitude, @longitude) = args
      
        @encoded = self.class.encode(@latitude, @longitude)
      else
        raise InvalidArguments, "Invalid number of arguments to #{self.class}.new"
      end
    end
  
    def to_i(level = nil)
      level ? @encoded >> ((MAXIMUM_RESOLUTION - level) * 2) : @encoded
    end
  
    def to_a
      [ @latitude, @longitude ]
    end
  end
end
