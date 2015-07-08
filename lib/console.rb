#--
# Console v1.5 by Solistra and Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script provides an interactive Ruby console through the RGSS Console
# with support for user-defined macros (stored as external files) and the
# ability to step into and out of any Ruby object known at runtime. This is
# primarily a scripter's tool.
# 
#   In addition to the core script, you may also download a zipped package of
# default external macros which provide a number of useful tasks and general
# enhancements to the basic SES Console. The latest macro package may be
# downloaded from GitHub -- the latest release of the SES Console should have a
# .zip archive attached to it which provides the entire macro package ready to
# be placed in your configured macro directory. The package may be found here:
# 
#   * [SES Console Releases](https://github.com/sesvxace/console/releases)
# 
# Please be sure to read the included README.md file included with the package
# for more information about what it offers.
# 
# Advanced Usage
# -----------------------------------------------------------------------------
#   In order to activate the console, press F5 (by default -- this is able to
# be configured in the configuration area). By default, one line of code is
# evaluated at a time. To stop the interactive interpreter and return to the
# game, simply use the `exit` method provided by the `Kernel` module.
# 
#   **NOTE:** If you are in the context of an object which has an alternative
# `exit` method defined -- such as `SceneManager` -- you will have to call the
# `Kernel.exit` method explicitly or raise a `SystemExit` exception.
# 
#   **NOTE:** You may also use the `exit!` method provided by `Kernel` to close
# the game immediately directly from the console.
# 
#   The SES Console also allows you to change the context of the interactive
# interpreter at any time by binding it to any present Ruby object with the
# `SES::Console.bind` method. For example, to bind the interpreter to event 5
# on the current map, use the following:
# 
#     SES::Console.bind($game_map.events[5])
# 
#   All code entered into the interpreter from that point on would be evaluated
# in the context of event 5 on the current map. You can also bind the console
# to the top-level Ruby execution context by passing `TOPLEVEL_BINDING` to the
# `bind` method, which will evaluate code in `main`. To rebind the console back
# to the user-defined `CONTEXT`, use the method `SES::Console.reset_binding`.
# 
#   Note that changing the evaluation context via `SES::Console.bind` pushes
# the object being bound to onto an object stack; this stack can also be
# reversed with the `SES::Console.rebind` (also aliased as `unbind`) method,
# allowing you to quickly navigate multiple evaluation contexts:
# 
#     self # => SES::Console
#     SES::Console.bind(DataManager)
#     self # => DataManager
#     SES::Console.rebind
#     self # => SES::Console
# 
#   Calling `SES::Console.reset_binding` both resets the evaluation context to
# the default context and clears the object stack.
# 
#     SES::Console.reset_binding
#     SES::Console.stack # => []
# 
#   **NOTE:** You can also temporarily bind or rebind the SES Console's context
# by passing a block to the `SES::Console.bind`, `SES::Console.rebind`, and
# `SES::Console.reset_binding` methods like so:
# 
#     self # => SES::Console
#     SES::Console.bind(TOPLEVEL_BINDING) do
#       # Evaluation inside the block now takes place within `main`.
#       self # => main
#     end
#     self # => SES::Console
# 
#   In addition to this, the SES Console allows the use of external Ruby files
# known as 'macros.' These files must be stored in the configurable `MACRO_DIR`
# directory in your project's root directory. Each macro must have a unique
# file name to be recognized by this script. Macros may also be placed in
# subdirectories for organization, but file names *must* be unique. In order to
# execute an external macro, use the method `SES::Console.macro` with a symbol
# corresponding to the base name of the external macro you wish to use. For
# example, to call the macro 'Files/read_file.rb', use the following:
# 
#     SES::Console.macro(:read_file)
# 
#   **NOTE:** New macros added to the `MACRO_DIR` directory while the game is
# run in test mode will *not* be found automatically. If this occurs, you will
# have to rebuild the macro listing by calling the `SES::Console.load_macros`
# method. Once called, all detected macros will be added to the `@macros` hash.
# 
#   **NOTE:** By default, two macros have special functionality: 'setup' and
# 'teardown'. The 'setup' macro is run whenever the SES Console is opened via
# its `open` method, and the 'teardown' macro is run whenever the opened
# console has been closed. Use these macros for any code you want to be run
# whenever the console is opened or closed by user or script input.
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   Place this script below the SES Core (v2.0 or higher) script (if you are
# using it) or the Materials header, but above all other custom scripts. This
# script does not require the SES Core, but it is highly recommended.
# 
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # Console
  # ===========================================================================
  # Provides methods to facilitate an interactive Ruby console environment.
  module Console
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    
    # The directory used to store external macros. Relative to your project's
    # root directory.
    MACRO_DIR = 'System/Macros'
    
    # The `Input` module constant to use for enabling the console. Constants
    # referring to function keys are recommended (`Input::F5` - `Input::F9`).
    TRIGGER = Input::F5
    
    # The default evaluation context. Recommended values are either `self` or
    # `TOPLEVEL_BINDING` (which will cause evaluation to occur in `main`).
    CONTEXT = TOPLEVEL_BINDING
    
    # Hash of prompt styles for different interpreter states. These values are
    # used to create various prompts via `sprintf`.
    @prompt = {
      error:  '!> %s',
      input:  '>> %s: ',
      return: '=> %s'
    }
    
    # Hooks defined for use by the console; the defaults are recommended.
    @hooks = {
      pre_eval: ->(script, options) {},
      post_eval: ->(value, options) do
          puts @prompt[:return] % value.inspect unless options[:silent]
        end,
      eval_error: ->(error, options) do
          $stderr.puts @prompt[:error] % "#{error.class}: #{error.message}"
        end,
      on_open: ->(script) { macro(:setup) if @macros[:setup] },
      on_input: ->(script) do
          print @prompt[:input] % @context.eval('sinspect')
          puts script if script
        end,
      on_close: ->(script) do
          macro(:teardown) if @macros[:teardown]
          sleep(0.1) # Prevent input from unintentionally passing to the game.
        end,
    }
    
    # =========================================================================
    # END CONFIGURATION
    # =========================================================================
    
    # Object
    # =========================================================================
    # The superclass of all Ruby objects except `BasicObject`.
    class ::Object
      # Provides the internal binding of this object publicly.
      #
      # @note This cannot be defined as an alias -- the returned binding is not
      #   suitable.
      # 
      # @return [Binding] the object's internal binding
      def __binding__
        is_a?(Module) ? class_eval('binding') : binding
      end
    end
    
    class << self
      # Whether or not the REPL is currently enabled.
      # @return [Boolean]
      attr_accessor :enabled
      
      # The current execution scope of the console's REPL.
      # @return [Binding]
      attr_accessor :context
      
      # Hash of hooks used by the console.
      # @return [Hash{Symbol => Proc}]
      attr_reader :hooks
      
      # Hash of macro files recognized by the console.
      # @return [Hash{Symbol => String}]
      attr_reader :macros
      
      # Hash of prompt styles for the console's REPL.
      # @return [Hash{Symbol => String}]
      attr_reader :prompt
    end
    
    # Explicitly define the initial context for the Console to the binding of
    # the default `CONTEXT`.
    @context = CONTEXT.__binding__
    
    # Initialize the binding stack.
    @stack = []
    
    # Provides a reader method for the object stack, returning a duplicate
    # of the stack.
    #
    # @return [Array<Object>] an array of objects passed to the
    #   {SES::Console.bind} method
    def self.stack
      @stack.dup
    end
    
    # Performs macro definition from external .rb files in the `MACRO_DIR`
    # directory.
    # 
    # @note Macro files added while the SES Console is running will not be
    #   detected automatically. You must explicitly call this method in order
    #   to update the hash of known macro files.
    # 
    # @return [Hash{Symbol => String}] hash of macro file locations; keys are
    #   base names of files converted to symbols, values are relative paths to
    #   macro files
    # 
    # @see .macro
    def self.load_macros
      @macros = Dir["#{MACRO_DIR}/**/*.rb"].each_with_object({}) do |macro, h|
        h[File.basename(macro, '.*').to_sym] = macro
      end
    end
    
    # Sets the evaluation context of the SES Console to the passed object. The
    # context is only set for the duration of the block if one is given.
    # 
    # @see .rebind
    # @see .reset_binding
    # @return [Binding] the new evaluation context
    def self.bind(object, &block)
      if block_given?
        object.instance_exec(&block)
      else
        previous = @context.eval('self')
        @stack.push(previous) unless @stack.last == object
        @context = object.__binding__
      end
    end
    
    # Rebinds the SES Console's evaluation context to the previously bound
    # context. The context is only rebound for the duration of the block if one
    # is given.
    # 
    # @see .bind
    # @return [Binding] the rebound evaluation context
    def self.rebind(&block)
      if block_given?
        @stack.last.instance_exec(&block)
      else
        @context = @stack.empty? ? CONTEXT.__binding__ : @stack.pop.__binding__
      end
    end
    class << self ; alias_method :unbind, :rebind ; end
    
    # Resets the SES Console's evaluation context to the value of `CONTEXT` and
    # clears the object stack if no block is given. The context is only reset
    # for the duration of the block if one is given.
    # 
    # @see .bind
    # @return [Binding] the reset evaluation context
    def self.reset_binding(&block)
      if block_given?
        CONTEXT.instance_exec(&block)
      else
        @stack.clear
        @context = CONTEXT.__binding__
      end
    end
    
    # Silently evaluates the content of the macro file referenced by the passed
    # identifier.
    # 
    # @param id [Symbol] the macro ID to load
    # @raise [LoadError] if no macro with the given ID exists
    # @return [Object] the return value of the evaluated macro
    # 
    # @see .load_macros
    def self.macro(id)
      raise LoadError, "No macro '#{id.inspect}' found." unless @macros[id]
      evaluate(File.read(@macros[id]), silent: true)
    end
    
    # Performs evaluation of the passed string.
    # 
    # @note This method swallows all exceptions by design.
    # 
    # @param script [String] the script to evaluate
    # @param options [Hash{Symbol=>Object}] a hash of options
    # @return [Object] the return value of the passed script
    def self.evaluate(script, options = {})
      @hooks[:pre_eval].call(script, options)
      @hooks[:post_eval].call(value = @context.eval('_ = ' << script), options)
      value
    rescue SystemExit
      @enabled = false
    rescue Exception => ex
      @hooks[:eval_error].call(ex, options)
      ex
    end
    
    # Opens the console for evaluation. Evaluation will continue until the
    # SES Console is disabled or the passed script is completed.
    # 
    # @param script [String, nil] the script to evaluate; `nil` to evaluate
    #   user input
    # @return [void]
    def self.open(script = nil)
      @enabled = true
      load_macros unless @macros
      @hooks[:on_open].call(script)
      begin
        @hooks[:on_input].call(script)
        evaluate(script || gets)
        @enabled = false if script
      end while @enabled
      @hooks[:on_close].call(script)
    end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      # Script metadata.
      Description = Script.new(:Console, 1.5)
      Register.enter(Description)
    end
  end
end
# Graphics
# =============================================================================
# Module which handles all GDI+ screen drawing.
class << Graphics
  # Aliased to update the calling conditions for opening the SES Console.
  # 
  # @see #update
  alias_method :ses_console_gfx_upd, :update
  
  # Performs graphical updates and provides the global logic timer.
  # 
  # @return [void]
  def update
    SES::Console.open if Input.trigger?(SES::Console::TRIGGER)
    ses_console_gfx_upd
  end
end
# Object
# =============================================================================
# The superclass of all Ruby objects except `BasicObject`.
class Object
  # Returns a technical description of the object in the form of the object's
  # class and address within the Ruby runtime.
  # 
  # @return [String] the technical description string
  def __desc__
    hex_id = '0x' << (__id__.even? ? __id__ << 1 : __id__ / 2).to_s(16)
    "#{self.class.name}:#{hex_id}"
  end
  
  # Returns a string representing a simplified `inspect` call to the object.
  # 
  # @return [String] the simple inspection string
  def sinspect
    kind_of?(Numeric) ? inspect : "#<#{__desc__}>"
  end
end
# Module
# =============================================================================
# The superclass of {Class}; essentially a class without instantiation support.
class Module
  # Define the `__desc__` and `sinspect` methods as aliases for `name`.
  [:__desc__, :sinspect].each { |m| alias_method m, :name }
end
# TOPLEVEL_BINDING
# =============================================================================
# The singleton class of `TOPLEVEL_BINDING`.
class << TOPLEVEL_BINDING
  # Returns a simplified description of the `TOPLEVEL_BINDING`.
  # 
  # @return [String] "main"
  def __desc__
    'main'
  end
  
  # Define the `sinspect`, `inspect`, and `to_s` methods as aliases for
  # `__desc__`.
  [:sinspect, :inspect, :to_s].each { |m| alias_method m, :__desc__ }
end
