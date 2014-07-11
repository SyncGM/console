#--
# SES Console: Extensions
# =============================================================================
#   Provides general extensions to the default Ruby environment used by RPG
# Maker to allow easier use of the SES Console and provide general debugging
# methods.
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # Console
  # ===========================================================================
  # Provides methods to facilitate an interactive Ruby console environment.
  module Console
    # Prompts related to multiline editing.
    @prompt[:multiline] = '^  '
    @prompt[:multi_end] = '<<'
    
    # Enables multiple lines of input. This method collects strings of user
    # input until the input string matches the given `end_of_input` string (the
    # `:multi_end` value of the `@prompt` hash by default) and returns the
    # entirety of the collected input.
    # 
    # @param end_of_input [String] the end-of-input delimiter to use
    # @return [String] the collected input
    def self.multiline(end_of_input = @prompt[:multi_end])
      script = ''
      loop do
        print(@prompt[:multiline])
        break if (input = gets).chomp == end_of_input
        script << input
      end
      script
    end
  end
end
# Object
# =============================================================================
# Superclass of all objects except `BasicObject`.
class Object
  # Provides a sorted array of the instance methods defined on this object in
  # particular.
  # 
  # @return [Array<Symbol>] a sorted list of instance methods
  def instance_methods
    (methods - self.class.superclass.methods).sort!
  end
  
  # Determines if the object is included in the given collection.
  # 
  # @example
  #   1.in?([1, 2, 3]) # => true
  # 
  # @param other [Object] the collection to test against
  # @return [Boolean] `true` if the callee is in the given collection, `false`
  #   otherwise
  def in?(other)
    other.include?(self) rescue false
  end
  
  # Returns the object itself.
  # 
  # @return [self]
  def itself
    self
  end
end
# Enumerable
# =============================================================================
# Standard module included in collections.
module Enumerable
  # Recursively calls `Enumerable#map!` with the given arguments on the
  # collection in the given order, effectively chaining them together. Objects
  # with a defined `#call` method may be chained, as well; in this case, the
  # return value of `#call` is mapped to each object in the collection.
  # 
  # @example
  #   [33, 50, 75].chain!(:to_f, ->(i) { i / 3 }, :round) # => [11, 17, 25]
  # 
  # @param list [Array<Symbol, #call>] list of method symbols and Proc objects
  #   to chain
  # @return [Object] the result of the method chain
  # 
  # @see #chain
  def chain!(*list)
    return self if list.empty?
    map! do |item|
      method = list.first
      method.respond_to?(:call) ? method.call(item) : item.send(method)
    end.chain!(*list.drop(1))
  end
  
  # Copies the object this method is called upon via `dup` before calling
  # {#chain!}, ensuring non-destructive chaining.
  # 
  # @see #chain!
  def chain(*list)
    dup.chain!(*list)
  end
end
# String and Symbol
# =============================================================================
[String, Symbol].each do |base|
  # Provide the `~` unary operator for symbols and strings as a shortcut for
  # running macro files in the SES Console.
  # 
  # @example
  #   ~:read_file # Calls SES::Console.macro(:read_file)
  # 
  base.send(:define_method, :~) { SES::Console.macro(self.to_sym) }
end
# String
# =============================================================================
# Mutable representation of a string of characters.
class String
  # Attempts to convert the string into a fully resolved constant.
  # 
  # @example
  #   'SceneManager'.to_const # => SceneManager
  #   'Console'.to_const(SES) # => SES::Console
  # 
  # @param base [Constant] the base constant to begin resolution with
  # @return [Constant, nil] the fully resolved constant if found, `nil`
  #   otherwise
  def to_const(base = Object)
    split('::').reduce(base) { |obj, const| obj.const_get(const) }
  rescue NameError
    nil
  end
  
  # Converts the string into a Proc by first converting it to a Symbol and
  # calling `#to_proc` on the result.
  # 
  # @example
  #   string = 'to_f'
  #   [1, 2, 3].map(&string) # => [1.0, 2.0, 3.0]
  # 
  # @return [Proc] the requested Proc object
  def to_proc
    to_sym.to_proc
  end
end
# Kernel
# =============================================================================
# Methods defined here are automatically available to all Ruby objects.
module Kernel
  # Delegator for the {SES::Console.bind} method.
  # @see SES::Console.bind
  def bind(object, &block)
    SES::Console.bind(object, &block)
  end
  
  # Delegator for the {SES::Console.rebind} method.
  # @see SES::Console.rebind
  def rebind(&block)
    SES::Console.rebind(&block)
  end
  
  # Delegator for the {SES::Console.macro} method.
  # @see SES::Console.macro
  def macro(id)
    SES::Console.macro(id)
  end
  
  # Delegator for the {SES::Console.multiline} method.
  # @see SES::Console.multiline
  def multiline(end_of_input = SES::Console.prompt[:multi_end])
    SES::Console.multiline(end_of_input)
  end
  
  # Closes an open console session by raising a `SystemExit` exception. This is
  # particularly useful when the context is bound to an object which has its
  # own `exit` method defined (such as `SceneManager`).
  # 
  # @raise [SystemExit] if the console is enabled
  # @return [nil] if the console is disabled
  def close
    raise SystemExit if SES::Console.enabled
  end
end
# Main
# =============================================================================
# Link to SES::Console.
Console = SES::Console