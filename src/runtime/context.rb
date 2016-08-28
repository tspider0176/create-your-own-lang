# Context Of evaluation
# There is one missing piece we need to introduce in our runtime.
# It's the context of evaluation.
# The "Context" object encapsulates the environment of evaluation of a specific block of code.
# It will keep track of the following:
#  * Local variables
#  * The current value of "self", the object on which methods with no receivers are called,
#    eg.: "print" is like "self.print"
#  * The current class, the class on which methods a re defined with the "def" keyword.
class Context
  attr_accessor :locals, :current_self, :current_class

  def initialize(current_self, current_class = current_self.runtime_class)
    @locals = {}
    @current_self = current_self
    @current_class = current_class
  end
end
