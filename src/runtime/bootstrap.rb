require_relative './class'
require_relative './context'

# The last step is to bring the runtime to life by initializing the core classes and objects.
# This process is called bootstrapping.
# At first, no objects exist in the runtime.
# Before we can execute our first expression, we need to populate that runtime with a few objects:
# "Class", "Object", "true", "false", "nil" and a few core methods.

# First, we create a Ruby Hash in which we'll store all constants accessible from inside our runtime.
# Then, we populate this Hash with the core classes of our language.
Constants = {}

Constants["Class"] = AwesomeClass.new
Constants["Class"].runtime_class = Constants["Class"]
Constants["Object"] = AwesomeClass.new
Constants["Number"] = AwesomeClass.new
Constants["String"] = AwesomeClass.new

# The root context will be the starting point where all our programs will start their evaluation.
# Thie will also set the value of "self" at the root of our programs.
root_self = Constants["Object"].new
RootContext = Context.new(root_self)

# Everything is an object in our language, even "true", "false", and "nil".
# So they need to have a class too.
Constants["TrueClass"] = AwesomeClass.new
Constants["FalseClass"] = AwesomeClass.new
Constants["NilClass"] = AwesomeClass.new

Constants["true"] = Constants["TrueClass"].new_with_value(true)
Constants["false"] = Constants["FalseClass"].new_with_value(false)
Constants["nil"] = Constants["NilClass"].new_with_value(nil)

# Now that we have injected all the core classes into the runtime, we  can define methods on those classes.
# The first method we'll define will allow us to do "Object.new" or "Number.new".
# Keep in mind, "Object" or "Number" are instances od the "Class" class.
# By defining the "new" method on "Class", it will be accessible on all its instances.
Constants["Class"].def :new do |receiver, arguments|
  receiver.new
end

# Next, we'll define the "pring" method.
# Since we want to be able to call it from everywhere, we'll define it on "Object".
# Remember from the parser's "Call" rule, methods without any receiver will be sent to "self".
# So "print()" is the same as "self.print()", and "self" will always be an instance of "Object".
Constants["Object"].def :print do |receiver, arguments|
  puts arguments.first.ruby_value
  Constants["nil"] # We always want to return objetcs from our runtime
end
