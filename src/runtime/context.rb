class Context
  attr_accessor :locals, :current_self, :current_class

  def initialize(current_self, current_class = current_self.runtime_class)
    @locals = {}
    @current_self = current_self
    @current_class = current_class
  end
end
