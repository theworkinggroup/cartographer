require 'rubygems'
require 'test/unit'

require 'active_support'
require 'active_support/test_case'


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cartographer'

class Test::Unit::TestCase
end
