#--
# SES Console: Setup
# =============================================================================
#   This macro is automatically run whenever the SES Console is opened during
# game testing. Provides general initialization for the console and external
# macros.
#++
module SES::Console::Macros
  # ===========================================================================
  # Setup
  # ===========================================================================
  # Provides the welcome message and logic determining its display.
  module Setup
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    # Macro references to automatically load when the SES Console is opened for
    # the first time. Macros which set up an environment are recommended.
    # 
    # **NOTE:** These macro files are _loaded_, not passed to the SES Console's
    # `macro` method -- there is a difference in terms of execution.
    AUTO_LOAD = [
      :extensions,
      :files_setup,
      :shell_setup,
    ]
    
    # Default prompt to use for user input during macro evaluation.
    SES::Console.prompt[:macro] = '?> '
    # =========================================================================
    # END CONFIGURATION
    # =========================================================================
  end
  # ===========================================================================
  # Macros
  # ===========================================================================
  # Top-level namespace for the default SES Console macro package.
  class << self
    # Default prompt for user input during macro execution.
    attr_reader :prompt
  end
  
  # Assign the prompt to the appropriate `SES::Console.prompt` value.
  @prompt ||= SES::Console.prompt[:macro]
  
  # Customized writer for the user input prompt. Automatically updates the
  # prompt in both the `SES::Macros` and `SES::Console` modules.
  def prompt=(value)
    SES::Console.prompt[:macro] = value.to_s
    @prompt = SES::Console.prompt[:macro]
  end
  # ===========================================================================
  # Setup
  # ===========================================================================
  # Provides the welcome message and logic determining its display.
  module Setup
    class << self
      attr_accessor :message, :run
      alias :run? :run
    end
    
    # The default message to display when the SES Console is opened for the
    # first time during a given test run.
    @message = "Welcome to the SES Console.\n" <<
               'Type `exit` or `Kernel.exit` to return to the game.'
    
    # Writes the given message (`@message` by default) to standard output.
    def self.display_message(message = @message)
      STDOUT.puts(message)
    end
    
    # Display the message and set `@run` to true if the SES Console has not
    # yet been run during this test run.
    unless run?
      AUTO_LOAD.each do |macro|
        load SES::Console.instance_variable_get(:@macros)[macro]
      end
      display_message
      @run = true
    end
  end
end