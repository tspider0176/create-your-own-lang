require 'test/unit'
require_relative '../src/runtime/bootstrap'
require_relative '../src/runtime/class'
require_relative '../src/runtime/context'
require_relative '../src/runtime/method'

class RuntimeTest < Test::Unit::TestCase
  def test_runtime
    object = Constants["Object"].call("new")

    # assert object is an Object
    assert_equal Constants["Object"], object.runtime_class
  end
end
