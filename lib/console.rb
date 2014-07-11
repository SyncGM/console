#--
# Console v1.3 by Solistra and Enelvon
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
# configured in the configuration area). By default, one line of code is
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
# to the top-level Ruby execution context by passing `main` to the `bind`
# method, which will evaluate code in Main. To rebind the console back to the
# user-defined `CONTEXT`, use the method `SES::Console.rebind`.
# 
#   **NOTE:** You can also temporarily bind or rebind the SES Console's context
# by passing a block to the `SES::Console.bind` and `SES::Console.rebind`
# methods like so:
# 
#     self # => SES::Console
#     SES::Console.bind(main) do
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
#   **NOTE:** Two macros have special functionality: 'setup' and 'teardown'.
# The 'setup' macro is run whenever the SES Console is opened via its `open`
# method, and the 'teardown' macro is run whenever the opened console has been
# exited. Use these macros for any code you want to be run whenever the console
# is opened or exited by user or script input.
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   Place this script below the SES Core (v2.0) script (if you are using it) or
# the Materials header, but above all other custom scripts. This script does
# not require the SES Core (v2.0), but it is recommended.
# 
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # Win32
  # ===========================================================================
  # Contains references to Windows API functions.
  module Win32
    # Reference to the `BringWindowToTop` Windows API function.
    BringWindowToTop = Win32API.new('user32', 'BringWindowToTop', 'I', 'I')
    
    # Reference to the `FindWindow` Windows API function.
    FindWindow = Win32API.new('user32', 'FindWindow', 'PP', 'I')
    
    # Reference to the `GetConsoleTitle` Windows API function.
    GetConsoleTitle = Win32API.new('kernel32', 'GetConsoleTitle', 'PI', 'I')
    
    # Reference to the `SetConsoleTitle` Windows API function.
    SetConsoleTitle = Win32API.new('kernel32', 'SetConsoleTitle', 'P', 'I')
    
    # Obtains the title of the RGSS Console window.
    # 
    # @return [String] the title of the RGSS Console window
    def self.console_title
      GetConsoleTitle.call(buffer = "\0" * 256, buffer.length - 1)
      buffer.delete!("\0")
    end
    
    # Sets the title of the RGSS Console window to the passed title.
    # 
    # @param title [String, nil] the new console title; `nil` or `false` to
    #   reset the title to its default value
    # @return [String] the new console title
    def self.console_title=(title)
      SetConsoleTitle.call((title || 'RGSS Console').to_s)
    end
    
    # Brings the window referenced by the passed window handle to the top of
    # the Windows Z-order and focuses it. Returns true if the window was raised
    # successfully, false otherwise.
    # 
    # @param hwnd [FixNum] the window handle of the window to focus
    # @return [Boolean] `true` if the window was focused, `false` otherwise
    def self.focus(hwnd = HWND::Game) BringWindowToTop.call(hwnd) != 0 end
    
    # HWND
    # =========================================================================
    # Contains references to window handles used by the Windows API. Window
    # handles are found with explicit names to ensure that the window handles
    # are accurate for this game in particular.
    module HWND
      # The window handle for the RGSS Console window.
      Console = Win32::FindWindow.call(
        'ConsoleWindowClass', Win32.console_title)
      
      # The window handle for the RGSS Player window.
      Game    = Win32::FindWindow.call(
        'RGSS Player', load_data('Data/System.rvdata2').game_title)
    end
  end
  # Console
  # ===========================================================================
  # Provides methods to facilitate an interactive Ruby console environment.
  module Console
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    
    # The title of the console window.
    Win32.console_title =
      load_data('Data/System.rvdata2').game_title << ' Console'
    
    # The directory used to store external macros. Relative to your project's
    # root directory.
    MACRO_DIR = 'System/Macros'
    
    # The `Input` module constant to use for enabling the console. Constants
    # referring to function keys are recommended (`Input::F5` - `Input::F9`).
    TRIGGER = Input::F5
    
    # The default evaluation context. Recommended values are either `self` or
    # `TOPLEVEL_BINDING` (which will cause evaluation to occur in main).
    CONTEXT = self
    
    # Hash of prompt styles for different interpreter states.
    @prompt = {
      :error     => '!> ',
      :input     => '>> ',
      :multiline => '^  ',
      :multi_end => '<<' ,
      :return    => '=> '
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
      # @return [Binding] the object's internal binding
      def __binding__
        binding
      end
    end
    
    class << self
      # Whether or not the Console is currently enabled.
      # @return [Boolean]
      attr_accessor :enabled
      
      # The current execution scope of the Console's REPL.
      # @return [Binding]
      attr_accessor :context
      
      # Hash of prompt styles for the Console's REPL.
      # @return [Hash{Symbol => String}]
      attr_reader :prompt
    end
    
    @context = CONTEXT.__binding__
    
    # Redefined method to allow constants to be evaluated within the current
    # context. Without this, they would be viewed as nil unless present in
    # {SES::Console}.
    # 
    # @param sym [Symbol] symbol representing the missing constant
    # @raise [NameError] if the constant genuinely does not exist
    # @return [Constant] the resolved constant
    def self.const_missing(sym)
      @context == self ? super : @context.class.const_get(sym)
    rescue NameError => ex
      @context == self ? raise(ex) : @context.const_get(sym)
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
      Dir.mkdir(MACRO_DIR) unless Dir.exist?(MACRO_DIR)
      @macros = Dir["#{MACRO_DIR}/**/*.*"].each_with_object({}) do |macro, h|
        h[File.basename(macro, '.*').to_sym] = macro
      end
    end
    
    # Sets the evaluation context of the SES Console to the passed object. The
    # context is only set for the duration of the block if one is given.
    # 
    # @see .rebind
    def self.bind(object, &block)
      if block_given?
        object.instance_exec(&block)
      else
        @context = object.__binding__
        object
      end
    end
    
    # Rebinds the SES Console's evaluation context to the value of `CONTEXT`.
    # The context is only reset for the duration of the block if one is given.
    # 
    # @see .bind
    def self.rebind(&block)
      if block_given?
        CONTEXT.instance_exec(&block)
      else
        @context = CONTEXT.__binding__
        CONTEXT
      end
    end
    
    # Evaluates the content of the macro file referenced by the passed id.
    # 
    # @param id [Symbol] the macro ID to load
    # @raise [LoadError] if no macro with the given ID exists
    # @return [Object] the return value of the evaluated macro
    # 
    # @see .load_macros
    def self.macro(id)
      raise LoadError, "No macro '#{id}' found." unless @macros[id]
      evaluate(File.read(@macros[id]), true)
    end
    
    # Performs evaluation of the passed string. Evaluation may be performed
    # silently by passing a `true` value to the `silent` parameter.
    # 
    # @note This method swallows all exceptions by design.
    # 
    # @param script [String] the script to evaluate
    # @param silent [Boolean] whether or not to evaluate silently
    # @return [Object] the return value of the passed script
    def self.evaluate(script = '', silent = false, &block)
      v = block ? @context.instance_exec(&block) : eval(script, @context)
      unless silent
        print(@prompt[:return], v == Kernel.main ? 'main' : v.inspect, "\n")
      end
      v
    rescue SystemExit
      @enabled = false
      sleep(0.1) # Prevent input from unintentionally passing to the game.
      Win32.focus(Win32::HWND::Game)
    rescue Exception => ex
      print("#{@prompt[:error]}#{ex.class}: #{ex.message}\n")
      ex
    end
    
    # Opens the console for evaluation. Evaluation will continue until the
    # SES Console is disabled or the passed script is completed.
    # 
    # @param script [String, nil] the script to evaluate; `nil` to evaluate
    #   user input
    # @return [void]
    def self.open(script = nil, &block)
      load_macros unless @macros
      macro(:setup) if @macros[:setup]
      warn('** WARNING: Block given, script ignored. **') if block && script
      Win32.focus(Win32::HWND::Console) unless script || block_given?
      begin
        print(@prompt[:input]) unless script || block_given?
        evaluate(script || gets, &block)
        @enabled = false if script || block_given?
      end while @enabled
      macro(:teardown) if @macros[:teardown]
    end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      # Script metadata.
      Description = Script.new(:Console, 1.3)
      Register.enter(Description)
    end
  end
end
# Scene_Base
# =============================================================================
# Superclass of all scenes within the game.
class Scene_Base
  # Aliased to update the calling conditions for opening the SES Console.
  # 
  # @see #update
  alias_method :ses_console_sb_upd, :update
  
  # Performs scene update logic.
  # 
  # @return [void]
  def update(*args, &block)
    update_ses_console
    ses_console_sb_upd(*args, &block)
  end
  
  # Enables and opens the SES Console if the SES Console's configured `TRIGGER`
  # has been registered as triggered by the RMVX Ace `Input` module.
  # 
  # @return [void]
  def update_ses_console
    if Input.trigger?(SES::Console::TRIGGER)
      SES::Console.enabled = true
      SES::Console.open
    end
  end
end
# Kernel
# =============================================================================
# Methods defined here are automatically available to all Ruby objects.
module Kernel
  # Provides a direct reference to the top-level binding, commonly known as
  # "main".
  # 
  # @note A reference to the main object itself could be used, but that has
  #   some unintended side effects.
  # 
  # @return [Binding] the top-level binding
  def main
    TOPLEVEL_BINDING
  end
end
