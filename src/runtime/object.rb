# The "AwesomeObject" class is the central object of our runrime.
# Since everthing is an object in our language,
# everything we will put in the runtime needs to be an object, thus an instance of this class.
# "AwesomeObject"s have a class and can hold a ruby value.
# This will allow us to store data such as a string or a number in an object to keep track of its Ruby representation.
class AwesomeObject
  # Each object has a class(named "runtime_class" to prevent conflicts with Ruby's "class" keyword).
  # Optionally an object can hold a Ruby value.
  # Eg.: numbers and strings will store their number or string Ruby equvalent in that variable.
  attr_accessor :runtime_class, :ruby_value

  def initialize(runtime_class, ruby_value=self)
    @runtime_class = runtime_class
    @ruby_value = ruby_value
  end

  # Like a typical Class-based runtime model, we store methods in the class of the object.
  # When calling a method on an object, we need to first lookup that method in the class, and then call it.
  def call(method, arguments = [])
  @runtime_class.lookup(method).call(self, arguments)
 end
end
