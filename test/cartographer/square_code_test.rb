require File.expand_path(File.join('..', 'helper'), File.dirname(__FILE__))

class TestMap < ActiveSupport::TestCase
  def test_encoding
    [
      [ -89.9999, -179.9999 ],
      [ 89.9999, 179.9999 ],
      [ 0.0, 0.0 ],
      [ 10.0, 10.0 ],
      [ 20.0, 20.0 ]
    ].each do |lat_long|
      code = Cartographer::SquareCode.new(*lat_long)
      
      assert_equal "%.4f,%.4f" % lat_long, "%.4f,%.4f" % code.to_a

      recode = Cartographer::SquareCode.new(code)

      assert_equal "%.4f,%.4f" % lat_long, "%.4f,%.4f" % recode.to_a, "Recoding failed"
    end
  end

  def test_baseline
    [
      [ 0.0, 0.0, 0b111000000000000000000000000000000000000000000000000000000000000 ]
    ].each do |lat_long|
      code = Cartographer::SquareCode.new(lat_long[0], lat_long[1])

      assert_equal "%016b" % lat_long[2], "%016b" % code.to_i
    end
  end
  
  def test_quadrants
    [
      [ -45.0, 90.0, 0b100 ],
      [ -45.0, -90.0, 0b101 ],
      [ 45.0, 90.0, 0b110 ],
      [ 45.0, -90.0, 0b111 ]
    ].each do |lat_long|
      code = Cartographer::SquareCode.new(lat_long[0], lat_long[1])
      
      assert_equal "%03b" % lat_long[2], "%03b" % code.to_i(1)
    end
  end
end
