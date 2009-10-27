module Cartographer
  class SquareCode
    # == Constants ============================================================
  
    LOG2 = Math.log(2)
    LAT_BASE_SCALE = (2 << 32) / 360
    LONG_BASE_SCALE = (2 << 32) / 180
    
    BITMASKS = (0..29).collect do |i|
      1 << i
    end
  
    # == Properties ===========================================================

    attr_accessor :latitude, :longitude
    attr_accessor :square_x, :square_y

    # == Class Methods ========================================================
  
    def self.merge(a, b, zoom = 60)
      # Engage the MSB in the result to ensure no conflict with regions
      # at a lower precision.
      result = (1 << zoom)

      # Interleave lat and long on a bit-by-bit basis
      BITMASKS[0, (zoom / 2)].each_with_index do |m, o|
        result |= (a & m) << o
        result |= (b & m) << (o + 1)
      end

      result
    end
  
    def self.encoding_size(value)
      i = 30

      while (i > 0)
        if (value & (1 << (i * 2)) != 0)
          return i
        end
        i -= 1
      end
    
      nil
    end
  
    def self.split(value, zoom = 60)
      base = encoding_size(value)
    
      lat = 0
      long = 0
    
      offset = ((zoom / 2) - base)

      # Bxyxyxyxyxy => value
      #  Bxyxyxyxyx => ovalue
    
      ovalue = (value >> 1)
    
      base.times do |o|
        pmask = (1 << (o * 2))
      
        lat |= (value & pmask) >> o
        long |= (ovalue & pmask) >> o
      end

      [ lat << offset, long << offset ]
    end

    def self.encode(lat, long, level = nil)
      # level refers to "zoom level" where 0 is no zoom, 29 is maximum
      # although anything beyond 25 is virtually useless.

      # Encoding is done to the millionth of a degree, which for all
      # practical purposes should be sufficient since that is roughly
      # equivalent to a 3cm increment.
      enc_lat = ((lat.to_f + 90.0) * LAT_BASE_SCALE).to_i
      enc_long = ((long.to_f + 180.0) * LONG_BASE_SCALE).to_i

      # 30 bits of precision handles numbers in the range 0..536,870,912
      # since what is required is a minimum of 0..360,000,000

      # NOTES:
      #  * 30 bits represents a resolution of 0.033m
      #  * 15 bits represents a resolution of 363m
      level ||= 30

      result = merge(enc_lat, enc_long)

      # Reduce precision according to level parameter
      if (level and level > 0)
        result >>= ((30 - level) * 2)
      end

      result
    end

    def self.decode(square)
      (lat, long) = split(square)

      [
        lat.to_f / LAT_BASE_SCALE - 90.0,
        long.to_f / LONG_BASE_SCALE - 180.0
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
      mask =
        case (offset)
        when 0
          0xAAAAAAAAAAAAAAA
        when 1
          0x555555555555555
        end

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
  
    def initialize(encoded_or_lat, long = nil)
      if (long)
        # Lat/Long pair
        @latitude = encoded_or_lat
        @longitude = long
      
        @encoded = self.class.encode(@latitude, @longitude)
      else
        # Binary representation
        @encoded = encoded_or_lat
      end
    end
  
    def to_i(level = 0)
      (level > 0) ? @encoded >> (level * 2) : @encoded
    end
  
    def to_a
      [ @latitude, @longitude ]
    end
  end
end
