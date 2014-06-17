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
# Enumerable
# =============================================================================
# Standard module included in collections -- provides well-known methods such
# as `each` and `map`.
module Enumerable
  # Recursively calls `Enumerable#map!` with the given arguments on the
  # collection in the given order, effectively chaining them together. Objects
  # with a defined `#call` method may be chained, as well; in this case, the
  # return value of `#call` is mapped to each object in the collection.
  # 
  # Example:
  #     [33, 50, 75].chain!(:to_f, ->(i) { i / 3 }, :round) # => [11, 17, 25]
  def chain!(*list)
    return self if list.empty?
    map! do |item|
      method = list.first
      method.respond_to?(:call) ? method.call(item) : item.send(method)
    end.chain!(*list.drop(1))
  end
  
  # Copies the object this method is called upon via `dup` before calling
  # `chain!`, ensuring non-destructive chaining.
  def chain(*list)
    dup.chain!(*list)
  end
  
  # Returns the first item in the collection for which the passed block
  # evaluates to a value other than `false` or `nil`. Returns `nil` if no match
  # was found.
  # 
  # Example:
  #     [1, 3, 5, 8, 10].find_first(&:even?) # => 8
  def find_first
    each { |object| return object if yield object }
    nil
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
# String
# =============================================================================
# Mutable representation of a string of characters.
class String
  # Attempts to convert the string into a fully resolved constant. Will
  # recursively attempt to resolve the given argument if the argument is not
  # a kind of `Class` or `Module`.
  def to_const(base = Object)
    base = base.to_s.to_const unless [Class, Module].any? { |con| base == con }
    split('::').reduce(base) { |obj, const| obj.const_get(const) }
  rescue NameError
    nil
  end
  
  # Converts the string into a Proc by first converting it to a Symbol and
  # calling `#to_proc` on the result.
  # 
  # Example:
  #     string = 'to_f'
  #     [1, 2, 3].map(&string) # => [1.0, 2.0, 3.0]
  def to_proc
    to_sym.to_proc
  end
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