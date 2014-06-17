#--
# Console v1.2 by Solistra and Enelvon
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script provides an interactive Ruby console through the RGSS Console
# with support for user-defined macros (stored as external files), multiple
# lines of input, and the ability to step into and out of any Ruby object known
# at runtime. This is primarily a scripter's tool.
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
#   In order to evaluate multiple lines, use the `SES::Console.multiline`
# method and `eval` its output like so:
# 
#     eval SES::Console.multiline
# 
#   **NOTE:** The `SES::Console.multiline` method simply takes multiple lines
# of input and returns a string of the input -- it does not perform evaluation
# by itself. To end multiline input, simply enter the 'end of input' delimiter
# (`<<` by default, though this can be configured below).
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
#   As a final note, the console can also be used in a non-interactive mode by
# opening the console and passing a string to be immediately evaluated. This
# will run the passed string as if it were entered as input by an interactive
# user and then end console processing. This can be done by entering code into
# an event's Script Call command like so:
# 
#     SES::Console.open(%{puts 'Hi, there.'})
# 
#   You can also perform 'silent' evaluations (essentially, evaluation without
# the displayed return value) by passing a string to `SES::Console.evaluate`
# directly with a second argument of `true` to enable silent evaluation.
# Example (in a Script Call):
# 
#     SES::Console.evaluate(%{puts 'Hi, there.'}, true)
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
module SES
  # ===========================================================================
  # Win32
  # ===========================================================================
  # Contains references to Windows API functions.
  module Win32
    BringWindowToTop = Win32API.new('user32',   'BringWindowToTop', 'I',  'I')
    FindWindow       = Win32API.new('user32',   'FindWindow',       'PP', 'I')
    GetConsoleTitle  = Win32API.new('kernel32', 'GetConsoleTitle',  'PI', 'I')
    SetConsoleTitle  = Win32API.new('kernel32', 'SetConsoleTitle',  'P',  'I')
    
    # Returns the title of the RGSS Console window.
    def self.console_title
      GetConsoleTitle.call(buffer = "\0" * 256, buffer.length - 1)
      buffer.delete!("\0")
    end
    
    # Sets the title of the RGSS Console window to the passed title.
    def self.console_title=(title)
      SetConsoleTitle.call((title || 'RGSS Console').to_s)
    end
    
    # Brings the window referenced by the passed window handle to the top of
    # the Windows Z-order and focuses it. Returns true if the window was raised
    # successfully, false otherwise.
    def self.focus(hwnd = HWND::Game) BringWindowToTop.call(hwnd) != 0 end
    
    # =========================================================================
    # HWND
    # =========================================================================
    # Contains references to window handles used by the Windows API.
    module HWND
      # Window handles are found with explicit names to ensure that the window
      # handles are accurate for this game in particular.
      Console = Win32::FindWindow.call(
        'ConsoleWindowClass', Win32.console_title)
      Game    = Win32::FindWindow.call(
        'RGSS Player', load_data('Data/System.rvdata2').game_title)
    end
  end
  # ===========================================================================
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
    
    # The Input module constant to use for enabling the console. Constants that
    # refer to the function keys are recommended ('Input::F5' - 'Input::F9').
    TRIGGER = Input::F5
    
    # The default evaluation context. Recommended values are either 'self' or
    # 'TOPLEVEL_BINDING' (which will cause evaluation to occur in Main).
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
    @context = CONTEXT
    class << self
      attr_accessor :enabled, :context
      attr_reader   :prompt
    end

    # Redefined method to allow constants to be evaluated within the current
    # context. Without this, they would be viewed as nil unless present in
    # SES::Console.
    def self.const_missing(sym)
      @context == self ? super : @context.class.const_get(sym)
    rescue NameError => ex
      @context == self ? raise(ex) : @context.const_get(sym)
    end
    
    # Macro definition from external .rb files in the Macros directory. Macros
    # are stored as a hash where keys are the base names of .rb files converted
    # to symbols and values are relative paths to macro files.
    def self.load_macros
      Dir.mkdir(MACRO_DIR) unless Dir.exist?(MACRO_DIR)
      @macros = Dir["#{MACRO_DIR}/**/*.*"].each_with_object({}) do |macro, hash|
        hash[File.basename(macro, '.*').to_sym] = macro
      end
    end
    
    # Sets the evaluation context of the SES Console to the passed object. The
    # context is only set for the duration of the block if one is given.
    def self.bind(object, &block)
      block_given? ? object.instance_exec(&block) : @context = object
    end
    
    # Rebinds the SES Console's evaluation context to the value of CONTEXT. The
    # context is only reset for the duration of the block if one is given.
    def self.rebind(&block)
      block_given? ? CONTEXT.instance_exec(&block) : @context = CONTEXT
    end
    
    # Evaluates the content of the macro file referenced by the passed id.
    def self.macro(id)
      raise(LoadError.new("No macro '#{id}' found.")) unless @macros[id]
      evaluate(File.read(@macros[id]), true)
    end
    
    # Performs evaluation of the passed string. Evaluation may be performed
    # silently by passing a 'true' value to the 'silent' parameter.
    def self.evaluate(script = '', silent = false, &block)
      v = block ? @context.instance_exec(&block) : @context.send(:eval, script)
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
    
    # Enables multiple lines of input. This method collects strings of user
    # input until the input string matches the given end_of_input string (the
    # :multi_end value of the @prompt hash by default) and returns the entirety
    # of the collected input.
    def self.multiline(end_of_input = @prompt[:multi_end])
      script = ''
      loop do
        print(@prompt[:multiline])
        break if (input = gets).chomp == end_of_input
        script << input
      end
      script
    end
    
    # Opens the console for evaluation. Evaluation will continue until the
    # SES Console is disabled or the passed script is completed.
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
      Register.enter(Description = Script.new(:Console, 1.2))
    end
  end
end
# =============================================================================
# Scene_Base
# =============================================================================
# Superclass of all scenes within the game.
class Scene_Base
  # Aliased to update the calling conditions for opening the SES Console.
  alias :ses_console_sb_upd :update
  def update(*args, &block)
    update_ses_console
    ses_console_sb_upd(*args, &block)
  end
  
  # Enables and opens the SES Console if the SES Console's configured TRIGGER
  # has been registered as triggered by the RMVX Ace Input module.
  def update_ses_console
    if Input.trigger?(SES::Console::TRIGGER)
      SES::Console.enabled = true
      SES::Console.open
    end
  end
end if $TEST && SES::Win32::HWND::Console > 0
# =============================================================================
# Kernel
# =============================================================================
# Methods defined here are automatically available to all Ruby objects.
module Kernel
  # Provides a direct reference to the top-level binding, commonly known as
  # "main". A reference to the main object itself could be used, but that has
  # some unintended side effects.
  def main() TOPLEVEL_BINDING end
end