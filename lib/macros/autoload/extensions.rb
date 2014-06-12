#--
# SES Console: Extensions
# =============================================================================
#   Provides general extensions to the default Ruby environment used by RPG
# Maker to allow easier use of the SES Console and provide general debugging
# methods.
#++
# =============================================================================
# Object
# =============================================================================
# Superclass of all objects except BasicObject.
class Object
  # Provides a sorted array of the instance methods defined on this object in
  # particular.
  def instance_methods
    (methods - ::Object.methods).sort!
  end
  
  # Determines if the object is included in the given collection.
  def in?(other)
    other.include?(self) rescue false
  end
  
  # Returns the object itself.
  def itself
    self
  end
end
# =============================================================================
# String and Symbol
# =============================================================================
[String, Symbol].each do |base|
  # Provide the `~` unary operator for symbols and strings as a shortcut for
  # running macro files in the SES Console.
  base.send(:define_method, :~) { SES::Console.macro(self.to_sym) }
end
# =============================================================================
# Kernel
# =============================================================================
# Methods defined here are automatically available to all Ruby objects.
module Kernel
  # Delegators for the `bind`, `rebind`, `macro`, and `multiline` methods of
  # the SES Console.
  def bind(object, &block) SES::Console.bind(object, &block) end
  def rebind(&block)       SES::Console.rebind(&block)       end
  def macro(id)            SES::Console.macro(id)            end
  
  def multiline(end_of_input = SES::Console.prompt[:multi_end])
    SES::Console.multiline(end_of_input)
  end
  
  # Closes an open console session by raising a `SystemExit` exception. This is
  # particularly useful when the context is bound to an object which has its
  # own `exit` method defined (such as `SceneManager`).
  def close
    raise(SystemExit) if SES::Console.enabled
  end
end
# =============================================================================
# Main
# =============================================================================
# Link the Console constant to SES::Console.
Console = SES::Console