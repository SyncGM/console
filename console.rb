#--
# Console v1.0 by Solistra and Enelvon
# ==============================================================================
# 
# Summary
# ------------------------------------------------------------------------------
#   This script provides an interactive Ruby console through the RGSS Console
# with support for user-defined macros (stored as external files), multiple
# lines of input, and the ability to step into and out of any Ruby object known
# at runtime. This is primarily a scripter's tool.
# 
# Advanced Usage
# ------------------------------------------------------------------------------
#   In order to activate the console, press F5 (by default -- this is able to
# configured in the configuration area). By default, one line of code is
# evaluated at a time. To stop the interactive interpreter and return to the
# game, simply use the `exit` method provided by the Kernel module. (**NOTE:**
# If you are in the context of an object which has an alternative `exit` method
# defined -- such as SceneManager -- you will have to explicitly call the
# `Kernel.exit` method or raise a SystemExit exception.)
# 
#   In order to evaluate multiple lines, use the `Console.multiline` method and
# eval its output like so:
# 
#     eval Console.multiline
# 
#   **NOTE:** The `Console.multiline` method simply takes multiple lines of
# input and returns a string of the input -- it does not perform any evaluation
# by itself. To end multiline input, simply enter the 'end of input' delimiter
# (`<<` by default, though this can be configured below).
# 
#   The SES Console also allows you to change the context of the interactive
# interpreter at any time by binding it to any present Ruby object with the
# `Console.bind` method. For example, to bind the interpreter to event 5 on the
# current map, use the following:
# 
#     Console.bind($game_map.events[5])
# 
#   All code entered into the interpreter from that point on would be evaluated
# in the context of event 5 on the current map. You can also bind the console
# to the top-level Ruby execution context by passing the Main constant to the
# `Console.bind` method, which will evaluate code in Main. To rebind the console
# back to the SES::Console module, use the method `Console.rebind`.
# 
#   In addition to this, the SES Console allows the use of external Ruby files
# known as 'macros.' These files must be stored in the configurable MACRO_DIR
# directory in your project's root directory. Each macro must have a unique
# filename ending in the '.rb' file extension to be recognized by this script.
# Macros may also be placed in subdirectories for organization, but filenames
# *must* be unique. In order to execute an external macro, use the method
# `Console.macro` with a symbol corresponding to the base name of the external
# macro you wish to use. For example, to call the macro 'Files/read_file.rb',
# use the following:
# 
#     Console.macro(:read_file)
# 
#   **NOTE:** New macros added to the MACRO_DIR directory while the game is run
# in test mode will not be found automatically. If this occurs, you will have to
# manually rebuild the macro listing by calling the `Console.load_macros`
# method. Once called, all detected macros will be added to the @macros hash.
# 
#   **NOTE:** Two macros have special functionality: 'setup' and 'teardown'. The
# 'setup' macro is run whenever the SES Console is opened via its `open` method,
# and the 'teardown' macro is run whenever the opened console has been exited.
# Use these macros for any code you want to be run whenever the console is
# opened or exited by user or script input.
# 
#   As a final note, the console can also be used in a non-interactive mode by
# opening the console and passing a string to be immediately evaluated. This
# will run the passed string as if it were entered as input by an interactive
# user and then end console processing. This can be done by entering code into
# an event's Script Call command like so:
# 
#     Console.open(%{puts 'Hi, there.'})
# 
#   You can also perform 'silent' evaluations (essentially, evaluation without
# the displayed return value) by passing a string to the `Console.evaluate`
# method directly with a second argument of `true` to enable silent evaluation.
# Example (in a Script Call):
# 
#     Console.evaluate(%{puts 'Hi, there.'}, true)
# 
#   **NOTE:** The 'nil' return value of the 'puts' method is suppressed... but
# keep in mind that this suppresses the display of exceptions, too.
# 
# License
# ------------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license. View
# [this page](http://sesvxace.wordpress.com/license/) for more information.
# 
# Installation
# ------------------------------------------------------------------------------
#   Place this script below the SES Core (v2.0) script (if you are using it) or
# the Materials header, but above all other custom scripts. This script does not
# require the SES Core (v2.0), but it is recommended.
# 
#++
module SES
  #--
  # ============================================================================
  # Win32
  # ============================================================================
  #++
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
    def self.console_title=(title = nil)
      SetConsoleTitle.call(title || 'RGSS Console')
    end
    
    # Brings the window referenced by the passed window handle to the top of
    # the Windows Z-order and focuses it. Returns true if the window was raised
    # successfully, false otherwise.
    def self.focus(window_handle = HWND::Game)
      BringWindowToTop.call(window_handle) != 0
    end
    #--
    # ==========================================================================
    # HWND
    # ==========================================================================
    #++
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
  #--
  # ============================================================================
  # Console
  # ============================================================================
  #++
  # Provides methods to facilitate an interactive Ruby console environment.
  module Console
    # ==========================================================================
    # BEGIN CONFIGURATION
    # ==========================================================================
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
    @context = self
    
    # Hash of prompt styles for different interpreter states.
    @prompt = {
      :error     => '!> ',
      :input     => '>> ',
      :macro     => '?> ',
      :multiline => '^  ',
      :multi_end => '<<' ,
      :return    => '=> '
    }
    # ==========================================================================
    # END CONFIGURATION
    # ==========================================================================
    class << self
      attr_accessor :enabled, :context
      attr_reader   :prompt
    end

    # Redefined method to allow constants to be evaluated within the current
    # context. Without this, they would be viewed as nil unless present in
    # SES::Console.
    def self.const_missing(sym)
      begin
        @context == self ? super : @context.class.const_get(sym)
      rescue NameError => ex
        @context.const_get(sym) rescue raise(ex)
      end
    end
    
    # Macro definition from external .rb files in the Macros directory. Macros
    # are stored as a hash where keys are the base names of .rb files converted
    # to symbols and values are relative paths to macro files.
    def self.load_macros
      Dir.mkdir(MACRO_DIR) unless Dir.exist?(MACRO_DIR)
      @macros = Dir.glob("#{MACRO_DIR}/**/*.rb").each_with_object({}) do |m, h|
        h[File.basename(m, '.rb').to_sym] = m
      end
    end
    
    # Sets the evaluation context of the SES Console to the passed object.
    def self.bind(object)
      @context = object
    end
    
    # Rebinds the SES Console's evaluation context to the SES::Console module.
    def self.rebind
      @context = self
    end
    
    # Evaluates the content of the macro file referenced by the passed id.
    # NOTE: macros are evaluated silently -- that is, without explicitly showing
    # return values or exception information.
    def self.macro(id)
      raise(LoadError.new("No macro '#{id}' found.")) unless @macros[id]
      evaluate(File.open(@macros[id], 'r') { |f| f.read }, true)
    end
    
    # Performs evaluation of the passed string. Evaluation may be performed
    # silently by passing a 'true' value to the 'silent' parameter.
    def self.evaluate(script, silent = false)
      begin
        # Main script evaluation code. Allows scripts to be executed within the
        # context of the @context instance variable's stored object. Returns the
        # return value of the evaluated Ruby code.
        return_value = @context.send(:eval, script)
        print(@prompt[:return], return_value.inspect, "\n") unless silent
        return_value
      rescue SystemExit
        # Refocus on the Game.exe window and stop all SES Console evaluation if
        # the console has been exited with Kernel#exit or a raised SystemExit
        # exception.
        Win32.focus(Win32::HWND::Game)
        @enabled = false
      rescue Exception => ex
        # Print basic exception information and return the exception if any
        # form of exception is encountered during evaluation.
        print("#{@prompt[:error]}#{ex.class}: #{ex.message}\n") unless silent
        ex
      end
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
    def self.open(script = nil)
      load_macros unless @macros
      # Run the 'setup' macro if it exists.
      macro(:setup) if @macros[:setup]
      Win32.focus(Win32::HWND::Console) unless script
      begin
        print(@prompt[:input])
        evaluate(script || gets)
        @enabled = false if script
      end while @enabled
      # Run the 'teardown' macro if it exists.
      macro(:teardown) if @macros[:teardown]
    end
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      Description = Script.new(:Console, 1.0)
      Register.enter(Description)
    end
  end
end
#--
# ==============================================================================
# Scene_Base
# ==============================================================================
#++
class Scene_Base
  # Only update the SES Console's enabled status if the game is being run in
  # test mode and the console window is shown.
  if $TEST && SES::Win32::HWND::Console > 0
    alias :ses_console_sb_upd :update
    def update(*args, &block)
      update_ses_console
      ses_console_sb_upd(*args, &block)
    end
    
    def update_ses_console
      # Enable and open the SES Console if the SES Console's configured TRIGGER
      # has been registered as triggered by the RMVX Ace Input module.
      if Input.trigger?(SES::Console::TRIGGER)
        SES::Console.enabled = true
        SES::Console.open
      end
    end
  end
end
#--
# ==============================================================================
# Main
# ==============================================================================
#++
# Linking the Console constant in main to SES::Console. This allows you to use
# the console from the top-level namespace with Console instead of SES::Console.
Console = SES::Console

# Likewise, linking the Main constant to a reference to the top-level binding.
# We could use a reference to main itself, but that has unintended side effects
# (such as constants defined being available to all objects, not just main).
Main = TOPLEVEL_BINDING