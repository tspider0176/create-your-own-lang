require_relative './object'

# Remember that in Awesome, everything is an object.
# Even classes are instances of the "AwesomeClass" class.
# "AwesomeClass"es hold the methods and can be instantiated via their "new" method.

# Classes are objects in Awecome so they inherit from AwesomeObject
class AwesomeClass < AwesomeObject
  attr_accessor :runtime_methods

  def initialize
    @runtime_methods = {}
    @runtime_class = Constants["Class"]
  end

  # Look up a method
  def lookup(method_name)
    method = @runtime_methods[method_name]
    raise "Method not found: #{method_name}" if method.nil?

    method
  end

  # Helper method to define a method on this class from Ruby.
  def def(name, &block)
    @runtime_methods[name.to_s] = block
  end

  # Create a new instance of this class
  def new
    AwesomeObject.new(self)
  end

  # Create an instance of this Awesome class that holds a Ruby value.
  # Like String, Number, or true.
  def new_with_value(value)
    AwesomeObject.new(self, value)
  end
end
